/// TTS Configuration
/// Konfiguration für den FlüssigTTS-Service

class TtsConfig {
  /// Unterstützte Sprachen mit ihren Stimmen
  static const Map<String, TtsVoiceConfig> voices = {
    'bs-BA': TtsVoiceConfig(
      language: 'bs-BA',
      edgeVoice: 'bs-BA-VesnaNeural',
      azureVoice: 'bs-BA-VesnaNeural',
      googleVoice: 'hr-HR-Standard-A', // Fallback zu Kroatisch
      displayName: 'Vesna (Bosnisch)',
    ),
    'de-DE': TtsVoiceConfig(
      language: 'de-DE',
      edgeVoice: 'de-DE-KatjaNeural',
      azureVoice: 'de-DE-KatjaNeural',
      googleVoice: 'de-DE-Standard-A',
      displayName: 'Katja (Deutsch)',
    ),
    'en-US': TtsVoiceConfig(
      language: 'en-US',
      edgeVoice: 'en-US-JennyNeural',
      azureVoice: 'en-US-JennyNeural',
      googleVoice: 'en-US-Standard-C',
      displayName: 'Jenny (Englisch)',
    ),
    'hr-HR': TtsVoiceConfig(
      language: 'hr-HR',
      edgeVoice: 'hr-HR-GabrijelaNeural',
      azureVoice: 'hr-HR-GabrijelaNeural',
      googleVoice: 'hr-HR-Standard-A',
      displayName: 'Gabrijela (Kroatisch)',
    ),
    'sr-RS': TtsVoiceConfig(
      language: 'sr-RS',
      edgeVoice: 'sr-RS-SophieNeural',
      azureVoice: 'sr-RS-SophieNeural',
      googleVoice: 'sr-RS-Standard-A',
      displayName: 'Sophie (Serbisch)',
    ),
    'tr-TR': TtsVoiceConfig(
      language: 'tr-TR',
      edgeVoice: 'tr-TR-EmelNeural',
      azureVoice: 'tr-TR-EmelNeural',
      googleVoice: 'tr-TR-Standard-A',
      displayName: 'Emel (Türkisch)',
    ),
  };

  /// Standard-Sprechgeschwindigkeit (0.5 - 2.0)
  static const double defaultRate = 0.9;

  /// Standard-Tonhöhe (0.5 - 2.0)
  static const double defaultPitch = 1.1;

  /// Audio-Format für Edge/Azure TTS
  static const String audioFormat = 'audio-24khz-48kbitrate-mono-mp3';

  /// Cache-Größe in MB
  static const int maxCacheSizeMb = 50;

  /// Cache-Dauer in Tagen
  static const int cacheDurationDays = 30;

  /// Häufige Phrasen zum Vorladen (pro Sprache)
  static const Map<String, List<String>> commonPhrases = {
    'bs-BA': [
      'Bravo!',
      'Super!',
      'Odlično!',
      'Tako je!',
      'Fantastično!',
      'Hajde probaj opet!',
      'Skoro!',
      'Ne brini, pokušaj ponovo!',
      'Ti to možeš!',
      'Samo nastavi!',
      'Zdravo prijatelju!',
      'Doviđenja!',
    ],
    'de-DE': [
      'Super!',
      'Toll!',
      'Ausgezeichnet!',
      'Richtig!',
      'Fantastisch!',
      'Versuch es nochmal!',
      'Fast!',
      'Du schaffst das!',
      'Weiter so!',
      'Hallo Freund!',
      'Tschüss!',
    ],
    'en-US': [
      'Great job!',
      'Awesome!',
      'You got it!',
      'Perfect!',
      'Amazing!',
      'Try again!',
      'Almost!',
      'You can do it!',
      'Keep going!',
      'Hello friend!',
      'Goodbye!',
    ],
  };
}

/// Konfiguration für eine einzelne Stimme
class TtsVoiceConfig {
  final String language;
  final String edgeVoice;
  final String azureVoice;
  final String googleVoice;
  final String displayName;

  const TtsVoiceConfig({
    required this.language,
    required this.edgeVoice,
    required this.azureVoice,
    required this.googleVoice,
    required this.displayName,
  });
}
