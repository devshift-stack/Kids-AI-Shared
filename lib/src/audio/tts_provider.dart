import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'tts_config.dart';

/// TTS Provider Typen
enum TtsProviderType { edge, azure, google, offline }

/// Abstrakte Basis für TTS Provider
abstract class TtsProvider {
  final Dio _dio = Dio();

  /// Generiert Audio-Daten für den gegebenen Text
  Future<Uint8List?> synthesize(String text, String language);

  /// Provider-Name für Logging
  String get name;

  /// Ob der Provider verfügbar ist
  Future<bool> isAvailable();
}

/// Edge TTS Provider (Kostenlos, unbegrenzt)
/// Nutzt die gleichen Stimmen wie Azure über den Edge-Browser-Endpoint
class EdgeTtsProvider extends TtsProvider {
  // HTTP Endpoint (WebSocket wäre für Streaming-Anwendungen)
  static const String _httpEndpoint =
      'https://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1';

  @override
  String get name => 'Edge TTS';

  @override
  Future<bool> isAvailable() async {
    try {
      // Einfacher Health-Check
      return true; // Edge ist fast immer verfügbar
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Uint8List?> synthesize(String text, String language) async {
    try {
      final voiceConfig = TtsConfig.voices[language];
      if (voiceConfig == null) return null;

      final voice = voiceConfig.edgeVoice;
      final ssml = _buildSsml(text, voice);

      // Edge TTS über HTTP POST
      final response = await _dio.post(
        _httpEndpoint,
        data: ssml,
        options: Options(
          headers: {
            'Content-Type': 'application/ssml+xml',
            'X-Microsoft-OutputFormat': TtsConfig.audioFormat,
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/91.0.864.59',
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      }
      return null;
    } catch (e) {
      print('Edge TTS Error: $e');
      return null;
    }
  }

  String _buildSsml(String text, String voice) {
    // Escape XML special characters
    final escapedText = text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');

    return '''
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="${voice.split('-').take(2).join('-')}">
  <voice name="$voice">
    <prosody rate="${((TtsConfig.defaultRate - 1) * 100).toInt()}%" pitch="${((TtsConfig.defaultPitch - 1) * 50).toInt()}%">
      $escapedText
    </prosody>
  </voice>
</speak>
''';
  }
}

/// Azure TTS Provider (500k Free/Monat)
class AzureTtsProvider extends TtsProvider {
  final String subscriptionKey;
  final String region;

  AzureTtsProvider({
    required this.subscriptionKey,
    this.region = 'westeurope',
  });

  @override
  String get name => 'Azure TTS';

  String get _endpoint =>
      'https://$region.tts.speech.microsoft.com/cognitiveservices/v1';

  @override
  Future<bool> isAvailable() async {
    return subscriptionKey.isNotEmpty;
  }

  @override
  Future<Uint8List?> synthesize(String text, String language) async {
    try {
      final voiceConfig = TtsConfig.voices[language];
      if (voiceConfig == null) return null;

      final voice = voiceConfig.azureVoice;
      final ssml = _buildSsml(text, voice, language);

      final response = await _dio.post(
        _endpoint,
        data: ssml,
        options: Options(
          headers: {
            'Content-Type': 'application/ssml+xml',
            'X-Microsoft-OutputFormat': TtsConfig.audioFormat,
            'Ocp-Apim-Subscription-Key': subscriptionKey,
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      }
      return null;
    } catch (e) {
      print('Azure TTS Error: $e');
      return null;
    }
  }

  String _buildSsml(String text, String voice, String language) {
    final escapedText = text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');

    return '''
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="$language">
  <voice name="$voice">
    <prosody rate="${((TtsConfig.defaultRate - 1) * 100).toInt()}%" pitch="${((TtsConfig.defaultPitch - 1) * 50).toInt()}%">
      $escapedText
    </prosody>
  </voice>
</speak>
''';
  }
}

/// Google Cloud TTS Provider (1 Mio Free/Monat)
class GoogleTtsProvider extends TtsProvider {
  final String apiKey;

  GoogleTtsProvider({required this.apiKey});

  @override
  String get name => 'Google TTS';

  static const String _endpoint =
      'https://texttospeech.googleapis.com/v1/text:synthesize';

  @override
  Future<bool> isAvailable() async {
    return apiKey.isNotEmpty;
  }

  @override
  Future<Uint8List?> synthesize(String text, String language) async {
    try {
      final voiceConfig = TtsConfig.voices[language];
      if (voiceConfig == null) return null;

      final response = await _dio.post(
        '$_endpoint?key=$apiKey',
        data: {
          'input': {'text': text},
          'voice': {
            'languageCode': language.split('-').take(2).join('-'),
            'name': voiceConfig.googleVoice,
          },
          'audioConfig': {
            'audioEncoding': 'MP3',
            'speakingRate': TtsConfig.defaultRate,
            'pitch': (TtsConfig.defaultPitch - 1) * 10,
          },
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 && response.data['audioContent'] != null) {
        return base64Decode(response.data['audioContent']);
      }
      return null;
    } catch (e) {
      print('Google TTS Error: $e');
      return null;
    }
  }
}
