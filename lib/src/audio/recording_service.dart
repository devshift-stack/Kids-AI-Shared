import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'recording_config.dart';
import 'stt_provider.dart';

/// Recording Service für Spracheingabe
/// Unterstützt On-Device und Cloud-basierte Spracherkennung
class RecordingService {
  RecordingService._();

  static RecordingService? _instance;

  /// Singleton-Instanz
  static RecordingService get instance {
    _instance ??= RecordingService._();
    return _instance!;
  }

  // State
  bool _isInitialized = false;
  RecognitionStatus _status = RecognitionStatus.ready;
  SttLanguageConfig _currentLanguage = SttLanguages.defaultLanguage;
  RecordingSettings _settings = RecordingSettings.forKids;

  // Services
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();

  // Provider für Cloud-STT
  SttProviderBase? _cloudProvider;

  // Callbacks
  void Function(RecognitionResult)? onResult;
  void Function(RecognitionStatus)? onStatusChange;
  void Function(RecognitionError)? onError;
  void Function(double)? onSoundLevel;

  // Getters
  RecognitionStatus get status => _status;
  bool get isListening => _status == RecognitionStatus.listening;
  bool get isProcessing => _status == RecognitionStatus.processing;
  bool get isReady => _status == RecognitionStatus.ready;
  SttLanguageConfig get currentLanguage => _currentLanguage;

  /// Initialisiert den Service
  Future<bool> initialize({
    SttLanguageConfig? language,
    RecordingSettings? settings,
    SttProviderBase? cloudProvider,
  }) async {
    if (_isInitialized) return true;

    _currentLanguage = language ?? SttLanguages.defaultLanguage;
    _settings = settings ?? RecordingSettings.forKids;
    _cloudProvider = cloudProvider;

    try {
      // Mikrofon-Berechtigung prüfen
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        _setStatus(RecognitionStatus.unavailable);
        onError?.call(RecognitionError.microphonePermissionDenied);
        return false;
      }

      // Speech-to-Text initialisieren (für On-Device)
      final available = await _speechToText.initialize(
        onStatus: _handleSttStatus,
        onError: _handleSttError,
        debugLogging: kDebugMode,
      );

      if (!available && _cloudProvider == null) {
        _setStatus(RecognitionStatus.unavailable);
        onError?.call(RecognitionError.speechNotAvailable);
        return false;
      }

      _isInitialized = true;
      _setStatus(RecognitionStatus.ready);
      return true;
    } catch (e) {
      _setStatus(RecognitionStatus.error);
      return false;
    }
  }

  /// Konfiguriert den Cloud-Provider
  void setCloudProvider(SttProviderBase provider) {
    _cloudProvider = provider;
  }

  /// Setzt die aktuelle Sprache
  void setLanguage(SttLanguageConfig language) {
    _currentLanguage = language;
  }

  /// Setzt die Recording-Einstellungen
  void setSettings(RecordingSettings settings) {
    _settings = settings;
  }

  /// Startet die Spracherkennung (On-Device)
  Future<void> startListening({
    SttLanguageConfig? language,
    bool useCloudFallback = true,
  }) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return;
    }

    if (_status == RecognitionStatus.listening) {
      return;
    }

    final lang = language ?? _currentLanguage;
    _setStatus(RecognitionStatus.listening);

    try {
      await _speechToText.listen(
        localeId: lang.locale,
        listenFor: Duration(seconds: _settings.listenForSeconds),
        pauseFor: Duration(seconds: _settings.pauseForSeconds),
        listenOptions: stt.SpeechListenOptions(
          partialResults: _settings.partialResults,
        ),
        onResult: (result) {
          final recognitionResult = RecognitionResult(
            text: result.recognizedWords,
            confidence: result.confidence,
            isFinal: result.finalResult,
            alternates: result.alternates
                .map((a) => a.recognizedWords)
                .toList(),
            language: lang.code,
          );

          onResult?.call(recognitionResult);

          if (result.finalResult) {
            _setStatus(RecognitionStatus.done);
          }
        },
        onSoundLevelChange: (level) {
          onSoundLevel?.call(level);
        },
      );
    } catch (e) {
      // Fallback zu Cloud-Provider
      if (useCloudFallback && _cloudProvider != null) {
        await _startCloudRecording(lang);
      } else {
        _setStatus(RecognitionStatus.error);
        onError?.call(RecognitionError(
          code: 'listen_error',
          message: e.toString(),
        ));
      }
    }
  }

  /// Startet Cloud-basierte Aufnahme
  Future<void> _startCloudRecording(SttLanguageConfig language) async {
    if (_cloudProvider == null) {
      onError?.call(RecognitionError.speechNotAvailable);
      return;
    }

    _setStatus(RecognitionStatus.listening);

    try {
      final tempDir = await getTemporaryDirectory();
      final audioPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Aufnahme starten
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: audioPath,
      );

      // Warten auf Aufnahmedauer oder manuelles Stoppen
      await Future.delayed(Duration(seconds: _settings.listenForSeconds));

      // Aufnahme stoppen und transkribieren
      await _stopAndTranscribe(audioPath, language);
    } catch (e) {
      _setStatus(RecognitionStatus.error);
      onError?.call(RecognitionError(
        code: 'cloud_recording_error',
        message: e.toString(),
      ));
    }
  }

  /// Stoppt Cloud-Aufnahme und transkribiert
  Future<void> _stopAndTranscribe(
    String audioPath,
    SttLanguageConfig language,
  ) async {
    await _audioRecorder.stop();
    _setStatus(RecognitionStatus.processing);

    if (_cloudProvider == null) {
      _setStatus(RecognitionStatus.error);
      return;
    }

    try {
      final result = await _cloudProvider!.transcribe(audioPath, language);
      onResult?.call(result);
      _setStatus(RecognitionStatus.done);
    } catch (e) {
      _setStatus(RecognitionStatus.error);
      onError?.call(RecognitionError(
        code: 'transcription_error',
        message: e.toString(),
      ));
    } finally {
      // Temporäre Datei löschen
      final file = File(audioPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// Stoppt die Spracherkennung
  Future<void> stopListening() async {
    if (_status != RecognitionStatus.listening) {
      return;
    }

    try {
      await _speechToText.stop();

      if (await _audioRecorder.isRecording()) {
        final path = await _audioRecorder.stop();
        if (path != null && _cloudProvider != null) {
          await _stopAndTranscribe(path, _currentLanguage);
          return;
        }
      }

      _setStatus(RecognitionStatus.ready);
    } catch (e) {
      _setStatus(RecognitionStatus.error);
    }
  }

  /// Bricht die Spracherkennung ab
  Future<void> cancel() async {
    try {
      await _speechToText.cancel();

      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }

      _setStatus(RecognitionStatus.ready);
    } catch (_) {
      _setStatus(RecognitionStatus.ready);
    }
  }

  /// Prüft Mikrofon-Berechtigung
  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Fordert Mikrofon-Berechtigung an
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Gibt verfügbare Sprachen zurück (On-Device)
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) return [];
    return await _speechToText.locales();
  }

  /// Prüft ob eine Sprache verfügbar ist (On-Device)
  Future<bool> isLanguageAvailable(String localeId) async {
    final locales = await getAvailableLocales();
    return locales.any((l) => l.localeId == localeId);
  }

  void _setStatus(RecognitionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      onStatusChange?.call(newStatus);
    }
  }

  void _handleSttStatus(String status) {
    switch (status) {
      case 'listening':
        _setStatus(RecognitionStatus.listening);
        break;
      case 'notListening':
        if (_status == RecognitionStatus.listening) {
          _setStatus(RecognitionStatus.processing);
        }
        break;
      case 'done':
        _setStatus(RecognitionStatus.done);
        break;
    }
  }

  void _handleSttError(dynamic error) {
    _setStatus(RecognitionStatus.error);

    if (error.errorMsg == 'error_no_match') {
      onError?.call(RecognitionError.noMatch);
    } else if (error.errorMsg == 'error_network') {
      onError?.call(RecognitionError.networkError);
    } else {
      onError?.call(RecognitionError(
        code: 'stt_error',
        message: error.errorMsg ?? 'Unbekannter Fehler',
      ));
    }
  }

  /// Gibt Ressourcen frei
  Future<void> dispose() async {
    await cancel();
    await _audioRecorder.dispose();
    _isInitialized = false;
  }
}

/// Einfache Hilfsfunktion für schnelle Spracherkennung
Future<RecognitionResult> listenForSpeech({
  SttLanguageConfig? language,
  Duration timeout = const Duration(seconds: 10),
}) async {
  final completer = Completer<RecognitionResult>();
  final service = RecordingService.instance;

  Timer? timeoutTimer;

  service.onResult = (result) {
    if (result.isFinal && !completer.isCompleted) {
      timeoutTimer?.cancel();
      completer.complete(result);
    }
  };

  service.onError = (error) {
    if (!completer.isCompleted) {
      timeoutTimer?.cancel();
      completer.complete(RecognitionResult.empty);
    }
  };

  timeoutTimer = Timer(timeout, () {
    if (!completer.isCompleted) {
      service.stopListening();
      completer.complete(RecognitionResult.empty);
    }
  });

  await service.startListening(language: language);

  return completer.future;
}
