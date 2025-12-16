import 'package:flutter/services.dart';

/// Pre-recorded Audio Service
/// Spielt voraufgenommene Audio-Dateien ab für feste Phrasen.
/// Spart API-Kosten da keine TTS-Calls nötig sind.
///
/// Struktur der Audio-Dateien:
/// assets/audio/{sprache}/{typ}_{nummer}.mp3
/// Beispiel: assets/audio/bs/correct_1.mp3
class PreRecordedAudioService {
  // Singleton
  static final PreRecordedAudioService _instance = PreRecordedAudioService._internal();
  factory PreRecordedAudioService() => _instance;
  PreRecordedAudioService._internal();

  String _currentLanguage = 'bs';

  /// Verfügbare Phrasen pro Typ und Sprache
  static const Map<String, Map<String, List<String>>> phrases = {
    'bs': {
      'correct': ['Bravo!', 'Super!', 'Odlično!', 'Tako je!', 'Fantastično!'],
      'wrong': ['Hajde probaj opet!', 'Skoro!', 'Ne brini, pokušaj ponovo!'],
      'encourage': ['Ti to možeš!', 'Samo nastavi!', 'Vjerujem u tebe!'],
      'hello': ['Zdravo prijatelju!', 'Ćao!', 'Hej, drago mi je što si tu!'],
      'bye': ['Doviđenja!', 'Vidimo se!', 'Bilo je super, ćao!'],
      'thinking': ['Hmm, razmišljam...', 'Daj da vidim...', 'Zanimljivo...'],
    },
    'de': {
      'correct': ['Super!', 'Toll!', 'Ausgezeichnet!', 'Richtig!', 'Fantastisch!'],
      'wrong': ['Versuch es nochmal!', 'Fast!', 'Keine Sorge, probier es nochmal!'],
      'encourage': ['Du schaffst das!', 'Weiter so!', 'Ich glaube an dich!'],
      'hello': ['Hallo Freund!', 'Hi!', 'Hey, schön dass du da bist!'],
      'bye': ['Tschüss!', 'Bis bald!', 'Das hat Spaß gemacht, tschüss!'],
      'thinking': ['Hmm, lass mich nachdenken...', 'Mal sehen...', 'Interessant...'],
    },
    'en': {
      'correct': ['Great job!', 'Awesome!', 'You got it!', 'Perfect!', 'Amazing!'],
      'wrong': ['Try again!', 'Almost!', 'Don\'t worry, try once more!'],
      'encourage': ['You can do it!', 'Keep going!', 'I believe in you!'],
      'hello': ['Hello friend!', 'Hi there!', 'Hey, I\'m glad you\'re here!'],
      'bye': ['Goodbye!', 'See you soon!', 'That was fun, bye!'],
      'thinking': ['Hmm, let me think...', 'Let me see...', 'Interesting...'],
    },
    'hr': {
      'correct': ['Bravo!', 'Super!', 'Odlično!', 'Tako je!', 'Fantastično!'],
      'wrong': ['Pokušaj opet!', 'Skoro!', 'Ne brini, probaj ponovno!'],
      'encourage': ['Možeš ti to!', 'Samo nastavi!', 'Vjerujem u tebe!'],
      'hello': ['Bok prijatelju!', 'Ćao!', 'Hej, drago mi je što si tu!'],
      'bye': ['Doviđenja!', 'Vidimo se!', 'Bilo je super, bok!'],
      'thinking': ['Hmm, razmišljam...', 'Da vidim...', 'Zanimljivo...'],
    },
    'sr': {
      'correct': ['Браво!', 'Супер!', 'Одлично!', 'Тако је!', 'Фантастично!'],
      'wrong': ['Пробај поново!', 'Скоро!', 'Не брини, покушај опет!'],
      'encourage': ['Можеш ти то!', 'Само настави!', 'Верујем у тебе!'],
      'hello': ['Здраво пријатељу!', 'Ћао!', 'Хеј, драго ми је што си ту!'],
      'bye': ['Довиђења!', 'Видимо се!', 'Било је супер, ћао!'],
      'thinking': ['Хмм, размишљам...', 'Да видим...', 'Занимљиво...'],
    },
    'tr': {
      'correct': ['Aferin!', 'Süper!', 'Mükemmel!', 'Doğru!', 'Harika!'],
      'wrong': ['Tekrar dene!', 'Neredeyse!', 'Endişelenme, bir daha dene!'],
      'encourage': ['Yapabilirsin!', 'Devam et!', 'Sana inanıyorum!'],
      'hello': ['Merhaba arkadaşım!', 'Selam!', 'Hey, burada olduğuna sevindim!'],
      'bye': ['Hoşça kal!', 'Görüşürüz!', 'Çok eğlenceliydi, bay bay!'],
      'thinking': ['Hmm, düşüneyim...', 'Bakalım...', 'İlginç...'],
    },
  };

  /// Setzt die aktuelle Sprache
  void setLanguage(String languageCode) {
    _currentLanguage = languageCode.split('-').first;
  }

  /// Prüft ob eine Phrase voraufgenommen existiert
  bool hasPreRecordedAudio(String type) {
    return phrases[_currentLanguage]?.containsKey(type) ?? false;
  }

  /// Gibt den Audio-Pfad für einen Phrasen-Typ zurück
  /// Wählt zufällig eine der verfügbaren Varianten
  String? getAudioPath(String type) {
    final langPhrases = phrases[_currentLanguage]?[type];
    if (langPhrases == null || langPhrases.isEmpty) return null;

    final index = DateTime.now().millisecond % langPhrases.length;
    return 'assets/audio/$_currentLanguage/${type}_${index + 1}.mp3';
  }

  /// Gibt den Text für einen Phrasen-Typ zurück (für Untertitel)
  String? getPhraseText(String type) {
    final langPhrases = phrases[_currentLanguage]?[type];
    if (langPhrases == null || langPhrases.isEmpty) return null;

    final index = DateTime.now().millisecond % langPhrases.length;
    return langPhrases[index];
  }

  /// Gibt alle Phrasen-Typen zurück
  static List<String> get allTypes => ['correct', 'wrong', 'encourage', 'hello', 'bye', 'thinking'];

  /// Gibt alle Sprachen zurück
  static List<String> get allLanguages => ['bs', 'de', 'en', 'hr', 'sr', 'tr'];

  /// Generiert Liste aller benötigten Audio-Dateien (für Aufnahme-Checkliste)
  static Map<String, List<AudioFileInfo>> generateRecordingList() {
    final result = <String, List<AudioFileInfo>>{};

    for (final lang in allLanguages) {
      result[lang] = [];
      final langPhrases = phrases[lang];
      if (langPhrases == null) continue;

      for (final type in allTypes) {
        final typePhrases = langPhrases[type];
        if (typePhrases == null) continue;

        for (var i = 0; i < typePhrases.length; i++) {
          result[lang]!.add(AudioFileInfo(
            fileName: '${type}_${i + 1}.mp3',
            text: typePhrases[i],
            type: type,
            language: lang,
          ));
        }
      }
    }

    return result;
  }

  /// Prüft ob alle Audio-Dateien für eine Sprache vorhanden sind
  Future<AudioCheckResult> checkAudioFiles(String language) async {
    final missing = <String>[];
    final found = <String>[];

    final langPhrases = phrases[language];
    if (langPhrases == null) {
      return AudioCheckResult(language: language, found: [], missing: [], isComplete: false);
    }

    for (final type in allTypes) {
      final typePhrases = langPhrases[type];
      if (typePhrases == null) continue;

      for (var i = 0; i < typePhrases.length; i++) {
        final path = 'assets/audio/$language/${type}_${i + 1}.mp3';
        try {
          await rootBundle.load(path);
          found.add(path);
        } catch (e) {
          missing.add(path);
        }
      }
    }

    return AudioCheckResult(
      language: language,
      found: found,
      missing: missing,
      isComplete: missing.isEmpty,
    );
  }
}

/// Info über eine Audio-Datei (für Aufnahme-Checkliste)
class AudioFileInfo {
  final String fileName;
  final String text;
  final String type;
  final String language;

  const AudioFileInfo({
    required this.fileName,
    required this.text,
    required this.type,
    required this.language,
  });

  String get fullPath => 'assets/audio/$language/$fileName';

  @override
  String toString() => '[$language] $type: "$text" → $fileName';
}

/// Ergebnis der Audio-Datei-Prüfung
class AudioCheckResult {
  final String language;
  final List<String> found;
  final List<String> missing;
  final bool isComplete;

  const AudioCheckResult({
    required this.language,
    required this.found,
    required this.missing,
    required this.isComplete,
  });

  int get totalCount => found.length + missing.length;
  int get foundCount => found.length;
  int get missingCount => missing.length;
  double get completionPercentage => totalCount > 0 ? foundCount / totalCount * 100 : 0;
}
