import 'package:flutter_test/flutter_test.dart';
import 'package:kids_ai_shared/src/audio/tts_config.dart';

void main() {
  group('TtsConfig', () {
    group('voices Map', () {
      test('enthaelt alle erwarteten Sprachen', () {
        expect(TtsConfig.voices.containsKey('bs-BA'), isTrue);
        expect(TtsConfig.voices.containsKey('de-DE'), isTrue);
        expect(TtsConfig.voices.containsKey('en-US'), isTrue);
        expect(TtsConfig.voices.containsKey('hr-HR'), isTrue);
        expect(TtsConfig.voices.containsKey('sr-RS'), isTrue);
        expect(TtsConfig.voices.containsKey('tr-TR'), isTrue);
      });

      test('hat 6 Sprachen', () {
        expect(TtsConfig.voices.length, equals(6));
      });

      test('alle Stimmen haben alle erforderlichen Felder', () {
        for (final entry in TtsConfig.voices.entries) {
          final voice = entry.value;
          expect(voice.language, isNotEmpty);
          expect(voice.edgeVoice, isNotEmpty);
          expect(voice.azureVoice, isNotEmpty);
          expect(voice.googleVoice, isNotEmpty);
          expect(voice.displayName, isNotEmpty);
        }
      });
    });

    group('childVoices Map', () {
      test('enthaelt Kinderstimmen fuer ausgewaehlte Sprachen', () {
        expect(TtsConfig.childVoices.containsKey('de-DE'), isTrue);
        expect(TtsConfig.childVoices.containsKey('en-US'), isTrue);
        expect(TtsConfig.childVoices.containsKey('tr-TR'), isTrue);
      });

      test('Kinderstimmen haben Kind im displayName', () {
        final deChild = TtsConfig.childVoices['de-DE'];
        expect(deChild?.displayName.contains('Kind'), isTrue);

        final enChild = TtsConfig.childVoices['en-US'];
        expect(enChild?.displayName.contains('Kind'), isTrue);
      });
    });

    group('getVoiceForChild', () {
      test('gibt childVoice fuer Kind <= 6 Jahre', () {
        final voice = TtsConfig.getVoiceForChild('de-DE', 5);

        expect(voice.displayName.contains('Kind'), isTrue);
      });

      test('gibt childVoice fuer Kind = 6 Jahre', () {
        final voice = TtsConfig.getVoiceForChild('de-DE', 6);

        expect(voice.displayName.contains('Kind'), isTrue);
      });

      test('gibt normale voice fuer Kind > 6 Jahre', () {
        final voice = TtsConfig.getVoiceForChild('de-DE', 7);

        expect(voice.displayName, equals('Katja (Deutsch)'));
        expect(voice.displayName.contains('Kind'), isFalse);
      });

      test('gibt normale voice fuer Kind = 10 Jahre', () {
        final voice = TtsConfig.getVoiceForChild('de-DE', 10);

        expect(voice.displayName.contains('Kind'), isFalse);
      });

      test('gibt normale voice wenn keine childVoice existiert', () {
        // bs-BA hat keine childVoice definiert
        final voice = TtsConfig.getVoiceForChild('bs-BA', 5);

        expect(voice.displayName, equals('Vesna (Bosnisch)'));
      });

      test('gibt en-US fallback fuer unbekannte Sprache', () {
        final voice = TtsConfig.getVoiceForChild('fr-FR', 10);

        expect(voice.language, equals('en-US'));
        expect(voice.displayName.contains('English'), isTrue);
      });

      test('handled age = 0', () {
        final voice = TtsConfig.getVoiceForChild('de-DE', 0);

        expect(voice, isNotNull);
        // 0 <= 6, also childVoice
        expect(voice.displayName.contains('Kind'), isTrue);
      });
    });

    group('supportedLanguages', () {
      test('gibt Liste aller Sprach-Codes', () {
        final languages = TtsConfig.supportedLanguages;

        expect(languages.contains('bs-BA'), isTrue);
        expect(languages.contains('de-DE'), isTrue);
        expect(languages.contains('en-US'), isTrue);
        expect(languages.length, equals(6));
      });
    });

    group('isLanguageSupported', () {
      test('gibt true fuer unterstuetzte Sprache', () {
        expect(TtsConfig.isLanguageSupported('de-DE'), isTrue);
        expect(TtsConfig.isLanguageSupported('bs-BA'), isTrue);
        expect(TtsConfig.isLanguageSupported('en-US'), isTrue);
      });

      test('gibt false fuer nicht-unterstuetzte Sprache', () {
        expect(TtsConfig.isLanguageSupported('fr-FR'), isFalse);
        expect(TtsConfig.isLanguageSupported('es-ES'), isFalse);
        expect(TtsConfig.isLanguageSupported(''), isFalse);
      });
    });

    group('commonPhrases', () {
      test('enthaelt Phrasen fuer alle Sprachen', () {
        for (final language in TtsConfig.supportedLanguages) {
          expect(
            TtsConfig.commonPhrases.containsKey(language),
            isTrue,
            reason: 'Fehlend: $language',
          );
        }
      });

      test('alle Phrasen-Listen sind nicht leer', () {
        for (final entry in TtsConfig.commonPhrases.entries) {
          expect(
            entry.value.isNotEmpty,
            isTrue,
            reason: '${entry.key} hat keine Phrasen',
          );
        }
      });

      test('deutsches Bravo existiert', () {
        expect(TtsConfig.commonPhrases['de-DE']?.contains('Super!'), isTrue);
      });

      test('bosnisches Bravo existiert', () {
        expect(TtsConfig.commonPhrases['bs-BA']?.contains('Bravo!'), isTrue);
      });

      test('englisches Great job existiert', () {
        expect(TtsConfig.commonPhrases['en-US']?.contains('Great job!'), isTrue);
      });
    });

    group('Konstanten', () {
      test('defaultRate ist sinnvoller Wert', () {
        expect(TtsConfig.defaultRate, greaterThanOrEqualTo(0.5));
        expect(TtsConfig.defaultRate, lessThanOrEqualTo(2.0));
        expect(TtsConfig.defaultRate, equals(0.9));
      });

      test('defaultPitch ist sinnvoller Wert', () {
        expect(TtsConfig.defaultPitch, greaterThanOrEqualTo(0.5));
        expect(TtsConfig.defaultPitch, lessThanOrEqualTo(2.0));
        expect(TtsConfig.defaultPitch, equals(1.1));
      });

      test('maxCacheSizeMb ist 50', () {
        expect(TtsConfig.maxCacheSizeMb, equals(50));
      });

      test('cacheDurationDays ist 30', () {
        expect(TtsConfig.cacheDurationDays, equals(30));
      });

      test('audioFormat ist mp3', () {
        expect(TtsConfig.audioFormat.contains('mp3'), isTrue);
      });
    });
  });

  group('TtsVoiceConfig', () {
    test('kann erstellt werden', () {
      const config = TtsVoiceConfig(
        language: 'de-DE',
        edgeVoice: 'de-DE-TestNeural',
        azureVoice: 'de-DE-TestNeural',
        googleVoice: 'de-DE-Standard-A',
        displayName: 'Test (Deutsch)',
      );

      expect(config.language, equals('de-DE'));
      expect(config.edgeVoice, equals('de-DE-TestNeural'));
      expect(config.displayName, equals('Test (Deutsch)'));
    });
  });
}
