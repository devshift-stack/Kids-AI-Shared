import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'recording_config.dart';

/// Abstrakte Klasse für Speech-to-Text Provider
abstract class SttProviderBase {
  /// Provider-Name
  String get name;

  /// Ist der Provider verfügbar?
  Future<bool> isAvailable();

  /// Transkribiert eine Audio-Datei
  Future<RecognitionResult> transcribe(
    String audioPath,
    SttLanguageConfig language,
  );

  /// Transkribiert Audio-Bytes
  Future<RecognitionResult> transcribeBytes(
    List<int> audioBytes,
    SttLanguageConfig language,
  );
}

/// Google Cloud Speech-to-Text Provider
class GoogleSttProvider extends SttProviderBase {
  GoogleSttProvider({
    required this.apiKey,
    this.enableAutomaticPunctuation = true,
    this.model = 'default',
  });

  final String apiKey;
  final bool enableAutomaticPunctuation;
  final String model;

  final Dio _dio = Dio();

  @override
  String get name => 'Google Cloud STT';

  @override
  Future<bool> isAvailable() async {
    return apiKey.isNotEmpty;
  }

  @override
  Future<RecognitionResult> transcribe(
    String audioPath,
    SttLanguageConfig language,
  ) async {
    final file = File(audioPath);
    if (!await file.exists()) {
      return RecognitionResult.empty;
    }
    final bytes = await file.readAsBytes();
    return transcribeBytes(bytes, language);
  }

  @override
  Future<RecognitionResult> transcribeBytes(
    List<int> audioBytes,
    SttLanguageConfig language,
  ) async {
    try {
      final base64Audio = base64Encode(audioBytes);

      final response = await _dio.post(
        'https://speech.googleapis.com/v1/speech:recognize?key=$apiKey',
        data: {
          'config': {
            'encoding': 'LINEAR16',
            'sampleRateHertz': 16000,
            'languageCode': language.googleCode,
            'enableAutomaticPunctuation': enableAutomaticPunctuation,
            'model': model,
          },
          'audio': {
            'content': base64Audio,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final results = data['results'] as List?;

        if (results != null && results.isNotEmpty) {
          final alternatives = results[0]['alternatives'] as List;
          if (alternatives.isNotEmpty) {
            final best = alternatives[0];
            return RecognitionResult(
              text: best['transcript'] ?? '',
              confidence: (best['confidence'] ?? 0.9).toDouble(),
              isFinal: true,
              alternates: alternatives
                  .skip(1)
                  .map((a) => a['transcript'] as String)
                  .toList(),
              language: language.code,
            );
          }
        }
      }

      return RecognitionResult.empty;
    } catch (e) {
      return RecognitionResult.empty;
    }
  }
}

/// Azure Speech-to-Text Provider
class AzureSttProvider extends SttProviderBase {
  AzureSttProvider({
    required this.subscriptionKey,
    required this.region,
  });

  final String subscriptionKey;
  final String region;

  final Dio _dio = Dio();

  @override
  String get name => 'Azure Speech';

  @override
  Future<bool> isAvailable() async {
    return subscriptionKey.isNotEmpty && region.isNotEmpty;
  }

  @override
  Future<RecognitionResult> transcribe(
    String audioPath,
    SttLanguageConfig language,
  ) async {
    final file = File(audioPath);
    if (!await file.exists()) {
      return RecognitionResult.empty;
    }
    final bytes = await file.readAsBytes();
    return transcribeBytes(bytes, language);
  }

  @override
  Future<RecognitionResult> transcribeBytes(
    List<int> audioBytes,
    SttLanguageConfig language,
  ) async {
    try {
      final response = await _dio.post(
        'https://$region.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1',
        queryParameters: {
          'language': language.azureCode,
        },
        options: Options(
          headers: {
            'Ocp-Apim-Subscription-Key': subscriptionKey,
            'Content-Type': 'audio/wav; codecs=audio/pcm; samplerate=16000',
          },
        ),
        data: Stream.fromIterable([audioBytes]),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final status = data['RecognitionStatus'];

        if (status == 'Success') {
          return RecognitionResult(
            text: data['DisplayText'] ?? '',
            confidence: (data['Confidence'] ?? 0.9).toDouble(),
            isFinal: true,
            language: language.code,
          );
        }
      }

      return RecognitionResult.empty;
    } catch (e) {
      return RecognitionResult.empty;
    }
  }
}

/// OpenAI Whisper Provider
class WhisperSttProvider extends SttProviderBase {
  WhisperSttProvider({
    required this.apiKey,
    this.model = 'whisper-1',
  });

  final String apiKey;
  final String model;

  final Dio _dio = Dio();

  @override
  String get name => 'OpenAI Whisper';

  @override
  Future<bool> isAvailable() async {
    return apiKey.isNotEmpty;
  }

  @override
  Future<RecognitionResult> transcribe(
    String audioPath,
    SttLanguageConfig language,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioPath,
          filename: 'audio.wav',
        ),
        'model': model,
        'language': language.whisperCode,
        'response_format': 'verbose_json',
      });

      final response = await _dio.post(
        'https://api.openai.com/v1/audio/transcriptions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return RecognitionResult(
          text: data['text'] ?? '',
          confidence: 0.95, // Whisper gibt keine Konfidenz zurück
          isFinal: true,
          language: data['language'] ?? language.code,
          durationMs: ((data['duration'] ?? 0) * 1000).toInt(),
        );
      }

      return RecognitionResult.empty;
    } catch (e) {
      return RecognitionResult.empty;
    }
  }

  @override
  Future<RecognitionResult> transcribeBytes(
    List<int> audioBytes,
    SttLanguageConfig language,
  ) async {
    // Whisper braucht eine Datei, also temporär speichern
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/whisper_temp.wav');
    await tempFile.writeAsBytes(audioBytes);

    try {
      return await transcribe(tempFile.path, language);
    } finally {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
}

/// Factory für STT Provider
class SttProviderFactory {
  SttProviderFactory._();

  /// Erstellt einen Provider basierend auf Typ und Konfiguration
  static SttProviderBase? create(
    SttProvider provider, {
    String? apiKey,
    String? subscriptionKey,
    String? region,
  }) {
    switch (provider) {
      case SttProvider.google:
        if (apiKey == null) return null;
        return GoogleSttProvider(apiKey: apiKey);

      case SttProvider.azure:
        if (subscriptionKey == null || region == null) return null;
        return AzureSttProvider(
          subscriptionKey: subscriptionKey,
          region: region,
        );

      case SttProvider.whisper:
        if (apiKey == null) return null;
        return WhisperSttProvider(apiKey: apiKey);

      case SttProvider.onDevice:
        // On-Device wird direkt über speech_to_text Package gehandhabt
        return null;
    }
  }
}
