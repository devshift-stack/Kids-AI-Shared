/// Recording und Speech-to-Text Konfiguration
/// Spracheinstellungen für alle unterstützten Sprachen

/// Speech-to-Text Provider
enum SttProvider {
  /// Geräte-eigene Spracherkennung (kostenlos, offline möglich)
  onDevice,

  /// Google Cloud Speech-to-Text
  google,

  /// Azure Speech Services
  azure,

  /// OpenAI Whisper
  whisper,
}

/// Unterstützte Sprachen für Speech-to-Text
class SttLanguageConfig {
  const SttLanguageConfig({
    required this.code,
    required this.locale,
    required this.name,
    required this.googleCode,
    required this.azureCode,
    required this.whisperCode,
  });

  /// Interner Sprachcode (bs, de, en, etc.)
  final String code;

  /// Vollständiger Locale (de-DE, en-US, etc.)
  final String locale;

  /// Sprachname
  final String name;

  /// Google Cloud Speech Sprachcode
  final String googleCode;

  /// Azure Speech Sprachcode
  final String azureCode;

  /// Whisper Sprachcode
  final String whisperCode;
}

/// Vorkonfigurierte Sprachen
class SttLanguages {
  SttLanguages._();

  static const bosnian = SttLanguageConfig(
    code: 'bs',
    locale: 'bs-BA',
    name: 'Bosanski',
    googleCode: 'bs-BA',
    azureCode: 'bs-BA',
    whisperCode: 'bs',
  );

  static const german = SttLanguageConfig(
    code: 'de',
    locale: 'de-DE',
    name: 'Deutsch',
    googleCode: 'de-DE',
    azureCode: 'de-DE',
    whisperCode: 'de',
  );

  static const english = SttLanguageConfig(
    code: 'en',
    locale: 'en-US',
    name: 'English',
    googleCode: 'en-US',
    azureCode: 'en-US',
    whisperCode: 'en',
  );

  static const croatian = SttLanguageConfig(
    code: 'hr',
    locale: 'hr-HR',
    name: 'Hrvatski',
    googleCode: 'hr-HR',
    azureCode: 'hr-HR',
    whisperCode: 'hr',
  );

  static const serbian = SttLanguageConfig(
    code: 'sr',
    locale: 'sr-RS',
    name: 'Srpski',
    googleCode: 'sr-RS',
    azureCode: 'sr-RS',
    whisperCode: 'sr',
  );

  static const turkish = SttLanguageConfig(
    code: 'tr',
    locale: 'tr-TR',
    name: 'Türkçe',
    googleCode: 'tr-TR',
    azureCode: 'tr-TR',
    whisperCode: 'tr',
  );

  /// Alle Sprachen
  static const all = [
    bosnian,
    german,
    english,
    croatian,
    serbian,
    turkish,
  ];

  /// Sprache nach Code finden
  static SttLanguageConfig? fromCode(String code) {
    try {
      return all.firstWhere((lang) => lang.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Standard-Sprache
  static const defaultLanguage = bosnian;
}

/// Recording-Einstellungen
class RecordingSettings {
  const RecordingSettings({
    this.sampleRate = 16000,
    this.channels = 1,
    this.bitRate = 128000,
    this.listenForSeconds = 10,
    this.pauseForSeconds = 2,
    this.partialResults = true,
    this.onDeviceOnly = false,
  });

  /// Abtastrate in Hz (16000 optimal für Sprache)
  final int sampleRate;

  /// Anzahl Kanäle (1 = Mono)
  final int channels;

  /// Bitrate
  final int bitRate;

  /// Maximale Aufnahmedauer in Sekunden
  final int listenForSeconds;

  /// Pause-Erkennung in Sekunden
  final int pauseForSeconds;

  /// Teilergebnisse während Aufnahme
  final bool partialResults;

  /// Nur On-Device Erkennung (offline)
  final bool onDeviceOnly;

  /// Standard-Einstellungen für Kinder (längere Pausen, kürzere Aufnahme)
  static const forKids = RecordingSettings(
    listenForSeconds: 15,
    pauseForSeconds: 3,
    partialResults: true,
  );

  /// Einstellungen für kurze Antworten
  static const forShortAnswers = RecordingSettings(
    listenForSeconds: 5,
    pauseForSeconds: 2,
    partialResults: false,
  );
}

/// Ergebnis einer Spracherkennung
class RecognitionResult {
  const RecognitionResult({
    required this.text,
    required this.confidence,
    required this.isFinal,
    this.alternates = const [],
    this.language,
    this.durationMs,
  });

  /// Erkannter Text
  final String text;

  /// Konfidenz (0.0 - 1.0)
  final double confidence;

  /// Ist das Ergebnis final?
  final bool isFinal;

  /// Alternative Erkennungen
  final List<String> alternates;

  /// Erkannte Sprache
  final String? language;

  /// Dauer der Aufnahme in Millisekunden
  final int? durationMs;

  /// Leeres Ergebnis
  static const empty = RecognitionResult(
    text: '',
    confidence: 0,
    isFinal: true,
  );

  /// Prüft ob Ergebnis leer ist
  bool get isEmpty => text.isEmpty;

  /// Prüft ob Ergebnis nicht leer ist
  bool get isNotEmpty => text.isNotEmpty;

  @override
  String toString() =>
      'RecognitionResult(text: "$text", confidence: $confidence, isFinal: $isFinal)';
}

/// Status der Spracherkennung
enum RecognitionStatus {
  /// Bereit zum Starten
  ready,

  /// Hört zu
  listening,

  /// Verarbeitet Sprache
  processing,

  /// Ergebnis verfügbar
  done,

  /// Fehler aufgetreten
  error,

  /// Nicht verfügbar
  unavailable,
}

/// Fehler bei der Spracherkennung
class RecognitionError {
  const RecognitionError({
    required this.code,
    required this.message,
    this.permanent = false,
  });

  final String code;
  final String message;
  final bool permanent;

  static const microphonePermissionDenied = RecognitionError(
    code: 'mic_permission',
    message: 'Mikrofonzugriff wurde verweigert',
    permanent: true,
  );

  static const speechNotAvailable = RecognitionError(
    code: 'speech_unavailable',
    message: 'Spracherkennung nicht verfügbar',
    permanent: true,
  );

  static const noMatch = RecognitionError(
    code: 'no_match',
    message: 'Keine Sprache erkannt',
  );

  static const networkError = RecognitionError(
    code: 'network',
    message: 'Netzwerkfehler',
  );

  static const timeout = RecognitionError(
    code: 'timeout',
    message: 'Zeitüberschreitung',
  );

  @override
  String toString() => 'RecognitionError($code: $message)';
}
