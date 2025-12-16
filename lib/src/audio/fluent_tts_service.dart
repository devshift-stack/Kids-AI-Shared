import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_config.dart';
import 'tts_provider.dart';
import 'tts_cache_manager.dart';
import 'pre_recorded_audio_service.dart';

/// Offline-Modus Optionen
enum OfflineMode {
  /// Automatisch erkennen (Standard)
  auto,
  /// Immer offline (kein Cloud TTS)
  forceOffline,
  /// Immer online versuchen
  forceOnline,
}

/// FlüssigTTS Service
/// Kombiniert Pre-recorded Audio, Cloud TTS und Offline-Fallback
/// für flüssige, unterbrechungsfreie Sprachausgabe
class FluentTtsService {
  // Singleton
  static FluentTtsService? _instance;
  static FluentTtsService get instance => _instance ??= FluentTtsService._();
  FluentTtsService._();

  // Audio Player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Offline TTS Fallback
  final FlutterTts _flutterTts = FlutterTts();

  // Provider (nach Priorität geordnet)
  final List<TtsProvider> _providers = [];

  // Cache
  final TtsCacheManager _cacheManager = TtsCacheManager.instance;

  // Pre-recorded Audio
  final PreRecordedAudioService _preRecorded = PreRecordedAudioService();

  // Status
  bool _isInitialized = false;
  String _currentLanguage = 'bs-BA';
  bool _isSpeaking = false;
  bool _isOffline = false;
  OfflineMode _offlineMode = OfflineMode.auto;

  // Callbacks
  void Function(String text)? onStartSpeaking;
  void Function()? onFinishSpeaking;
  void Function(String error)? onError;
  void Function(bool isOffline)? onConnectivityChanged;

  /// Aktueller Offline-Status
  bool get isOffline => _isOffline;

  /// Offline-Modus setzen
  set offlineMode(OfflineMode mode) {
    _offlineMode = mode;
    if (mode == OfflineMode.forceOffline) {
      _isOffline = true;
    } else if (mode == OfflineMode.forceOnline) {
      _isOffline = false;
    }
  }

  /// Initialisiert den Service
  /// [azureKey] - Optional: Azure Subscription Key
  /// [googleKey] - Optional: Google Cloud API Key
  Future<void> init({
    String? azureKey,
    String? googleKey,
  }) async {
    if (_isInitialized) return;

    print('FluentTTS: Initialisiere...');

    // Cache initialisieren
    await _cacheManager.init();

    // Provider hinzufügen (Priorität: Edge > Azure > Google)
    _providers.add(EdgeTtsProvider());

    if (azureKey != null && azureKey.isNotEmpty) {
      _providers.add(AzureTtsProvider(subscriptionKey: azureKey));
    }

    if (googleKey != null && googleKey.isNotEmpty) {
      _providers.add(GoogleTtsProvider(apiKey: googleKey));
    }

    // Offline TTS konfigurieren
    await _initOfflineTts();

    _isInitialized = true;
    print('FluentTTS: Bereit mit ${_providers.length} Cloud-Providern');
  }

  /// Konfiguriert flutter_tts als Offline-Fallback
  Future<void> _initOfflineTts() async {
    await _flutterTts.setSpeechRate(TtsConfig.defaultRate * 0.5);
    await _flutterTts.setPitch(TtsConfig.defaultPitch);
    await _flutterTts.setVolume(1.0);

    // Sprache setzen mit Fallback
    await _setOfflineLanguage(_currentLanguage);
  }

  /// Setzt die Offline-TTS Sprache mit Fallbacks
  Future<void> _setOfflineLanguage(String language) async {
    final fallbacks = {
      'bs-BA': ['hr-HR', 'sr-RS', 'de-DE'],
      'hr-HR': ['bs-BA', 'sr-RS', 'de-DE'],
      'sr-RS': ['hr-HR', 'bs-BA', 'de-DE'],
    };

    // Versuche primäre Sprache
    if (await _flutterTts.isLanguageAvailable(language)) {
      await _flutterTts.setLanguage(language);
      return;
    }

    // Versuche Fallbacks
    for (final fallback in fallbacks[language] ?? ['de-DE']) {
      if (await _flutterTts.isLanguageAvailable(fallback)) {
        await _flutterTts.setLanguage(fallback);
        return;
      }
    }
  }

  /// Setzt die aktuelle Sprache
  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    _preRecorded.setLanguage(language);
    await _setOfflineLanguage(language);
  }

  /// Spricht Text flüssig aus
  /// Nutzt Cache, Pre-recorded Audio oder generiert neu
  Future<void> speak(String text) async {
    if (!_isInitialized) await init();
    if (_isSpeaking) await stop();

    _isSpeaking = true;
    onStartSpeaking?.call(text);

    try {
      // 1. Pre-recorded Audio prüfen (für kurze Standardphrasen)
      final phraseType = _getPhraseType(text);
      if (phraseType != null) {
        final preRecordedPath = _preRecorded.getAudioPath(phraseType);
        if (preRecordedPath != null) {
          await _playAsset(preRecordedPath);
          return;
        }
      }

      // 2. Cache prüfen
      final cachedFile = await _cacheManager.getFromCache(text, _currentLanguage);
      if (cachedFile != null) {
        await _playFile(cachedFile);
        return;
      }

      // 3. Cloud TTS generieren
      final audioData = await _synthesizeWithFallback(text);
      if (audioData != null) {
        // In Cache speichern
        final file = await _cacheManager.saveToCache(
          text,
          _currentLanguage,
          audioData,
        );
        if (file != null) {
          await _playFile(file);
          return;
        }
      }

      // 4. Offline Fallback
      print('FluentTTS: Nutze Offline-Fallback');
      await _speakOffline(text);
    } catch (e) {
      onError?.call('Sprachausgabe fehlgeschlagen: $e');
      // Letzter Versuch: Offline
      await _speakOffline(text);
    } finally {
      _isSpeaking = false;
      onFinishSpeaking?.call();
    }
  }

  /// Spricht längeren Text mit Satz-Pufferung
  /// Lädt den nächsten Satz während der aktuelle abgespielt wird
  Future<void> speakLong(String text) async {
    if (!_isInitialized) await init();
    if (_isSpeaking) await stop();

    _isSpeaking = true;
    onStartSpeaking?.call(text);

    try {
      // Text in Sätze aufteilen
      final sentences = _splitIntoSentences(text);
      if (sentences.isEmpty) return;

      // Ersten Satz laden
      File? currentFile = await _getOrCreateAudioFile(sentences[0]);

      for (var i = 0; i < sentences.length; i++) {
        if (!_isSpeaking) break;

        // Nächsten Satz im Hintergrund vorladen
        Future<File?>? nextFileFuture;
        if (i + 1 < sentences.length) {
          nextFileFuture = _getOrCreateAudioFile(sentences[i + 1]);
        }

        // Aktuellen Satz abspielen
        if (currentFile != null) {
          await _playFile(currentFile);
        } else {
          await _speakOffline(sentences[i]);
        }

        // Kleine Pause zwischen Sätzen
        await Future.delayed(const Duration(milliseconds: 200));

        // Nächste Datei holen (sollte bereits geladen sein)
        if (nextFileFuture != null) {
          currentFile = await nextFileFuture;
        }
      }
    } catch (e) {
      onError?.call('Lange Sprachausgabe fehlgeschlagen: $e');
    } finally {
      _isSpeaking = false;
      onFinishSpeaking?.call();
    }
  }

  /// Holt Audio aus Cache oder generiert neu
  Future<File?> _getOrCreateAudioFile(String text) async {
    // Cache prüfen
    final cached = await _cacheManager.getFromCache(text, _currentLanguage);
    if (cached != null) return cached;

    // Generieren
    final audioData = await _synthesizeWithFallback(text);
    if (audioData != null) {
      return await _cacheManager.saveToCache(text, _currentLanguage, audioData);
    }
    return null;
  }

  /// Generiert Audio mit Provider-Failover
  Future<Uint8List?> _synthesizeWithFallback(String text) async {
    for (final provider in _providers) {
      try {
        if (await provider.isAvailable()) {
          final audio = await provider.synthesize(text, _currentLanguage);
          if (audio != null && audio.isNotEmpty) {
            print('FluentTTS: ${provider.name} erfolgreich');
            return audio;
          }
        }
      } catch (e) {
        print('FluentTTS: ${provider.name} fehlgeschlagen: $e');
      }
    }
    return null;
  }

  /// Spielt Asset-Audio ab (Pre-recorded)
  Future<void> _playAsset(String assetPath) async {
    try {
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
      await _audioPlayer.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
    } catch (e) {
      print('Asset abspielen fehlgeschlagen: $e');
      rethrow;
    }
  }

  /// Spielt Datei-Audio ab
  Future<void> _playFile(File file) async {
    try {
      await _audioPlayer.setFilePath(file.path);
      await _audioPlayer.play();
      await _audioPlayer.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
    } catch (e) {
      print('Datei abspielen fehlgeschlagen: $e');
      rethrow;
    }
  }

  /// Offline-TTS Fallback
  Future<void> _speakOffline(String text) async {
    final completer = Completer<void>();

    _flutterTts.setCompletionHandler(() {
      if (!completer.isCompleted) completer.complete();
    });

    _flutterTts.setErrorHandler((msg) {
      if (!completer.isCompleted) completer.completeError(msg);
    });

    await _flutterTts.speak(text);
    await completer.future;
  }

  /// Teilt Text in Sätze auf
  List<String> _splitIntoSentences(String text) {
    return text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Erkennt Phrasen-Typ für Pre-recorded Audio
  String? _getPhraseType(String text) {
    final normalized = text.toLowerCase().trim();

    // Exakte Matches für kurze Phrasen
    final typeMap = {
      'correct': ['bravo', 'super', 'odlično', 'tako je', 'fantastično',
                  'great', 'awesome', 'perfect', 'amazing', 'toll', 'richtig'],
      'wrong': ['probaj', 'opet', 'nochmal', 'try again', 'almost', 'fast', 'skoro'],
      'encourage': ['možeš', 'nastavi', 'vjerujem', 'du schaffst', 'weiter',
                    'you can', 'keep going', 'believe'],
      'hello': ['zdravo', 'ćao', 'hallo', 'hello', 'hi', 'hey'],
      'bye': ['doviđenja', 'vidimo', 'tschüss', 'goodbye', 'bye'],
      'thinking': ['razmišljam', 'vidim', 'nachdenken', 'thinking', 'let me'],
    };

    for (final entry in typeMap.entries) {
      for (final keyword in entry.value) {
        if (normalized.contains(keyword)) {
          return entry.key;
        }
      }
    }
    return null;
  }

  /// Stoppt die aktuelle Wiedergabe
  Future<void> stop() async {
    _isSpeaking = false;
    await _audioPlayer.stop();
    await _flutterTts.stop();
  }

  /// Lädt häufige Phrasen vor (beim App-Start aufrufen)
  Future<void> preloadCommonPhrases() async {
    if (!_isInitialized) await init();

    await _cacheManager.preloadPhrases(
      _currentLanguage,
      (text, language) => _synthesizeWithFallback(text),
    );
  }

  /// Cache-Statistiken
  Future<CacheStats> getCacheStats() async {
    return await _cacheManager.getStats();
  }

  /// Cache leeren
  Future<void> clearCache() async {
    await _cacheManager.clearCache();
  }

  /// Aufräumen
  Future<void> dispose() async {
    await stop();
    await _audioPlayer.dispose();
  }

  // ============================================================
  // OFFLINE-FUNKTIONEN
  // ============================================================

  /// Prüft Internet-Verbindung
  Future<bool> checkConnectivity() async {
    if (_offlineMode == OfflineMode.forceOffline) {
      _isOffline = true;
      return false;
    }
    if (_offlineMode == OfflineMode.forceOnline) {
      _isOffline = false;
      return true;
    }

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      final hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      if (_isOffline != !hasConnection) {
        _isOffline = !hasConnection;
        onConnectivityChanged?.call(_isOffline);
      }

      return hasConnection;
    } catch (e) {
      if (!_isOffline) {
        _isOffline = true;
        onConnectivityChanged?.call(true);
      }
      return false;
    }
  }

  /// Prüft ob Pre-recorded Audio für einen Phrasen-Typ verfügbar ist
  bool hasPreRecordedAudio(String phraseType) {
    return _preRecorded.hasPreRecordedAudio(phraseType);
  }

  /// Prüft ob Audio im Cache oder als Pre-recorded verfügbar ist
  Future<bool> hasOfflineAudio(String text) async {
    // Pre-recorded prüfen
    final phraseType = _getPhraseType(text);
    if (phraseType != null && _preRecorded.hasPreRecordedAudio(phraseType)) {
      return true;
    }

    // Cache prüfen
    return _cacheManager.hasCache(text, _currentLanguage);
  }

  /// Lädt alle Audio-Dateien für Offline-Nutzung vor
  /// Sollte bei WLAN-Verbindung aufgerufen werden
  Future<OfflinePreloadResult> preloadForOffline({
    List<String>? additionalTexts,
    void Function(int current, int total)? onProgress,
  }) async {
    if (!_isInitialized) await init();

    final textsToLoad = <String>[];

    // Standard-Phrasen aus Config
    final commonPhrases = TtsConfig.commonPhrases[_currentLanguage.split('-').first] ?? [];
    textsToLoad.addAll(commonPhrases);

    // Zusätzliche Texte
    if (additionalTexts != null) {
      textsToLoad.addAll(additionalTexts);
    }

    int loaded = 0;
    int failed = 0;
    int skipped = 0;

    for (var i = 0; i < textsToLoad.length; i++) {
      final text = textsToLoad[i];
      onProgress?.call(i + 1, textsToLoad.length);

      // Bereits im Cache?
      if (_cacheManager.hasCache(text, _currentLanguage)) {
        skipped++;
        continue;
      }

      // Pre-recorded verfügbar?
      final phraseType = _getPhraseType(text);
      if (phraseType != null && _preRecorded.hasPreRecordedAudio(phraseType)) {
        skipped++;
        continue;
      }

      // Generieren und cachen
      try {
        final audio = await _synthesizeWithFallback(text);
        if (audio != null) {
          await _cacheManager.saveToCache(text, _currentLanguage, audio);
          loaded++;
        } else {
          failed++;
        }
      } catch (e) {
        failed++;
      }

      // Kleine Pause
      await Future.delayed(const Duration(milliseconds: 50));
    }

    return OfflinePreloadResult(
      total: textsToLoad.length,
      loaded: loaded,
      failed: failed,
      skipped: skipped,
    );
  }

  /// Spricht im reinen Offline-Modus
  /// Nutzt nur Pre-recorded, Cache und flutter_tts
  Future<void> speakOfflineOnly(String text) async {
    if (!_isInitialized) await init();
    if (_isSpeaking) await stop();

    _isSpeaking = true;
    onStartSpeaking?.call(text);

    try {
      // 1. Pre-recorded Audio
      final phraseType = _getPhraseType(text);
      if (phraseType != null) {
        final preRecordedPath = _preRecorded.getAudioPath(phraseType);
        if (preRecordedPath != null) {
          try {
            await _playAsset(preRecordedPath);
            return;
          } catch (e) {
            // Asset nicht gefunden, weiter
          }
        }
      }

      // 2. Cache
      final cachedFile = await _cacheManager.getFromCache(text, _currentLanguage);
      if (cachedFile != null) {
        await _playFile(cachedFile);
        return;
      }

      // 3. flutter_tts Fallback
      await _speakOffline(text);
    } catch (e) {
      onError?.call('Offline-Sprachausgabe fehlgeschlagen: $e');
      // Letzter Versuch
      try {
        await _speakOffline(text);
      } catch (_) {}
    } finally {
      _isSpeaking = false;
      onFinishSpeaking?.call();
    }
  }

  /// Gibt Offline-Verfügbarkeit für Sprache zurück
  Future<OfflineAvailability> getOfflineAvailability() async {
    final cacheStats = await _cacheManager.getStats();
    final preRecordedCheck = await _preRecorded.checkAudioFiles(
      _currentLanguage.split('-').first,
    );

    // flutter_tts Sprache prüfen
    bool flutterTtsAvailable = false;
    try {
      flutterTtsAvailable = await _flutterTts.isLanguageAvailable(_currentLanguage);
      if (!flutterTtsAvailable) {
        // Fallback-Sprachen prüfen
        final fallbacks = ['hr-HR', 'sr-RS', 'de-DE'];
        for (final fb in fallbacks) {
          if (await _flutterTts.isLanguageAvailable(fb)) {
            flutterTtsAvailable = true;
            break;
          }
        }
      }
    } catch (e) {
      flutterTtsAvailable = false;
    }

    return OfflineAvailability(
      language: _currentLanguage,
      cachedPhrases: cacheStats.fileCount,
      preRecordedAvailable: preRecordedCheck.foundCount,
      preRecordedMissing: preRecordedCheck.missingCount,
      flutterTtsAvailable: flutterTtsAvailable,
    );
  }
}

/// Ergebnis des Offline-Preloads
class OfflinePreloadResult {
  final int total;
  final int loaded;
  final int failed;
  final int skipped;

  const OfflinePreloadResult({
    required this.total,
    required this.loaded,
    required this.failed,
    required this.skipped,
  });

  bool get isComplete => failed == 0;
  double get successRate => total > 0 ? (loaded + skipped) / total * 100 : 0;

  @override
  String toString() =>
      'OfflinePreload: $loaded geladen, $skipped übersprungen, $failed fehlgeschlagen (${successRate.toStringAsFixed(1)}%)';
}

/// Offline-Verfügbarkeit Info
class OfflineAvailability {
  final String language;
  final int cachedPhrases;
  final int preRecordedAvailable;
  final int preRecordedMissing;
  final bool flutterTtsAvailable;

  const OfflineAvailability({
    required this.language,
    required this.cachedPhrases,
    required this.preRecordedAvailable,
    required this.preRecordedMissing,
    required this.flutterTtsAvailable,
  });

  bool get isFullyOfflineCapable =>
      preRecordedMissing == 0 || flutterTtsAvailable;

  @override
  String toString() =>
      'Offline[$language]: $cachedPhrases cached, $preRecordedAvailable/$preRecordedMissing pre-recorded, flutter_tts: $flutterTtsAvailable';
}
