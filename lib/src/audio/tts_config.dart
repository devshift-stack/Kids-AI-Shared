/// TTS Configuration
/// Konfiguration für den FlüssigTTS-Service

class TtsConfig {
  /// Unterstützte Sprachen mit ihren Stimmen
  /// Hauptstimmen (freundlich, warm - ideal für Kinder)
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

  /// Alternative Kinderstimmen (höhere Tonlage, fröhlicher)
  /// Für jüngere Kinder (3-6 Jahre) können diese verwendet werden
  static const Map<String, TtsVoiceConfig> childVoices = {
    'de-DE': TtsVoiceConfig(
      language: 'de-DE',
      edgeVoice: 'de-DE-GiselaNeural', // Höhere, kindliche Stimme
      azureVoice: 'de-DE-GiselaNeural',
      googleVoice: 'de-DE-Standard-A',
      displayName: 'Gisela (Deutsch Kind)',
    ),
    'en-US': TtsVoiceConfig(
      language: 'en-US',
      edgeVoice: 'en-US-AnaNeural', // Kinderstimme
      azureVoice: 'en-US-AnaNeural',
      googleVoice: 'en-US-Standard-C',
      displayName: 'Ana (Englisch Kind)',
    ),
    'tr-TR': TtsVoiceConfig(
      language: 'tr-TR',
      edgeVoice: 'tr-TR-AhmetNeural', // Männlich aber jugendlich
      azureVoice: 'tr-TR-AhmetNeural',
      googleVoice: 'tr-TR-Standard-A',
      displayName: 'Ahmet (Türkisch)',
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
    'hr-HR': [
      'Bravo!',
      'Super!',
      'Odlično!',
      'Točno!',
      'Fantastično!',
      'Pokušaj opet!',
      'Skoro!',
      'Ne brini, probaj ponovno!',
      'Ti to možeš!',
      'Samo nastavi!',
      'Bok prijatelju!',
      'Doviđenja!',
    ],
    'sr-RS': [
      'Браво!',
      'Супер!',
      'Одлично!',
      'Тако је!',
      'Фантастично!',
      'Покушај поново!',
      'Скоро!',
      'Не брини, пробај опет!',
      'Ти то можеш!',
      'Само настави!',
      'Здраво другару!',
      'Довиђења!',
    ],
    'tr-TR': [
      'Aferin!',
      'Harika!',
      'Mükemmel!',
      'Doğru!',
      'Süper!',
      'Tekrar dene!',
      'Neredeyse!',
      'Yapabilirsin!',
      'Devam et!',
      'Merhaba arkadaş!',
      'Hoşça kal!',
      'Çok güzel!',
    ],
  };

  /// Hilfs-Methode: Gibt die beste Stimme für ein Kind zurück
  /// Für Kinder unter 6 Jahren wird eine Kinderstimme bevorzugt (wenn verfügbar)
  static TtsVoiceConfig getVoiceForChild(String language, int age) {
    if (age <= 6 && childVoices.containsKey(language)) {
      return childVoices[language]!;
    }
    return voices[language] ?? voices['en-US']!;
  }

  /// Alle verfügbaren Sprachen
  static List<String> get supportedLanguages => voices.keys.toList();

  /// Prüft ob eine Sprache unterstützt wird
  static bool isLanguageSupported(String language) =>
      voices.containsKey(language);
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
