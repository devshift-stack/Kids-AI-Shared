import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_ai_shared/src/theme/colors.dart';

void main() {
  group('KidsColors', () {
    group('Primary Colors', () {
      test('primary ist gueltige Color', () {
        expect(KidsColors.primary, isA<Color>());
      });

      test('primaryLight ist gueltige Color', () {
        expect(KidsColors.primaryLight, isA<Color>());
      });

      test('primaryDark ist gueltige Color', () {
        expect(KidsColors.primaryDark, isA<Color>());
      });

      test('primary hat erwarteten Hex-Wert', () {
        expect(KidsColors.primary, equals(const Color(0xFF6C5CE7)));
      });
    });

    group('Secondary Colors', () {
      test('secondary ist gueltige Color', () {
        expect(KidsColors.secondary, isA<Color>());
      });

      test('secondary hat erwarteten Hex-Wert', () {
        expect(KidsColors.secondary, equals(const Color(0xFF00CEC9)));
      });
    });

    group('Feedback Colors', () {
      test('success ist gueltige Color', () {
        expect(KidsColors.success, isA<Color>());
      });

      test('error ist gueltige Color', () {
        expect(KidsColors.error, isA<Color>());
      });

      test('warning ist gueltige Color', () {
        expect(KidsColors.warning, isA<Color>());
      });

      test('info ist gueltige Color', () {
        expect(KidsColors.info, isA<Color>());
      });

      test('alle Feedback-Farben haben Light-Varianten', () {
        expect(KidsColors.successLight, isA<Color>());
        expect(KidsColors.errorLight, isA<Color>());
        expect(KidsColors.warningLight, isA<Color>());
        expect(KidsColors.infoLight, isA<Color>());
      });

      test('alle Feedback-Farben haben Bg-Varianten', () {
        expect(KidsColors.successBg, isA<Color>());
        expect(KidsColors.errorBg, isA<Color>());
        expect(KidsColors.warningBg, isA<Color>());
        expect(KidsColors.infoBg, isA<Color>());
      });
    });

    group('Neutral Colors', () {
      test('background ist gueltige Color', () {
        expect(KidsColors.background, isA<Color>());
      });

      test('surface ist gueltige Color', () {
        expect(KidsColors.surface, isA<Color>());
      });

      test('textPrimary ist gueltige Color', () {
        expect(KidsColors.textPrimary, isA<Color>());
      });

      test('textSecondary ist gueltige Color', () {
        expect(KidsColors.textSecondary, isA<Color>());
      });

      test('border ist gueltige Color', () {
        expect(KidsColors.border, isA<Color>());
      });
    });

    group('Special Colors', () {
      test('star ist gueltige Color (Gold)', () {
        expect(KidsColors.star, isA<Color>());
        expect(KidsColors.star, equals(const Color(0xFFFFD700)));
      });

      test('Level-Farben existieren', () {
        expect(KidsColors.bronze, isA<Color>());
        expect(KidsColors.silver, isA<Color>());
        expect(KidsColors.gold, isA<Color>());
        expect(KidsColors.diamond, isA<Color>());
      });
    });

    group('Dark Theme Colors', () {
      test('darkBackground ist gueltige Color', () {
        expect(KidsColors.darkBackground, isA<Color>());
      });

      test('darkSurface ist gueltige Color', () {
        expect(KidsColors.darkSurface, isA<Color>());
      });

      test('darkTextPrimary ist gueltige Color', () {
        expect(KidsColors.darkTextPrimary, isA<Color>());
      });
    });

    group('avatarColors', () {
      test('enthaelt 8 Farben', () {
        expect(KidsColors.avatarColors.length, equals(8));
      });

      test('alle sind gueltige Colors', () {
        for (final color in KidsColors.avatarColors) {
          expect(color, isA<Color>());
        }
      });

      test('keine doppelten Farben', () {
        final uniqueColors = KidsColors.avatarColors.toSet();
        expect(uniqueColors.length, equals(KidsColors.avatarColors.length));
      });
    });

    group('randomAvatarColor', () {
      test('gibt eine Farbe aus avatarColors zurueck', () {
        final color = KidsColors.randomAvatarColor();

        expect(KidsColors.avatarColors.contains(color), isTrue);
      });
    });

    group('avatarColorAt', () {
      test('gibt korrekte Farbe fuer Index 0', () {
        expect(
          KidsColors.avatarColorAt(0),
          equals(KidsColors.avatarColors[0]),
        );
      });

      test('gibt korrekte Farbe fuer Index 7', () {
        expect(
          KidsColors.avatarColorAt(7),
          equals(KidsColors.avatarColors[7]),
        );
      });

      test('wrapped bei Index > 7', () {
        expect(
          KidsColors.avatarColorAt(8),
          equals(KidsColors.avatarColorAt(0)),
        );
        expect(
          KidsColors.avatarColorAt(9),
          equals(KidsColors.avatarColorAt(1)),
        );
        expect(
          KidsColors.avatarColorAt(16),
          equals(KidsColors.avatarColorAt(0)),
        );
      });

      test('handled sehr grosse Indizes', () {
        expect(
          KidsColors.avatarColorAt(100),
          equals(KidsColors.avatarColorAt(100 % 8)),
        );
      });
    });

    group('createMaterialColor', () {
      test('erstellt gueltige MaterialColor', () {
        final material = KidsColors.createMaterialColor(KidsColors.primary);

        expect(material, isA<MaterialColor>());
      });

      test('MaterialColor hat alle Schatten', () {
        final material = KidsColors.createMaterialColor(KidsColors.primary);

        expect(material[50], isA<Color>());
        expect(material[100], isA<Color>());
        expect(material[200], isA<Color>());
        expect(material[300], isA<Color>());
        expect(material[400], isA<Color>());
        expect(material[500], isA<Color>());
        expect(material[600], isA<Color>());
        expect(material[700], isA<Color>());
        expect(material[800], isA<Color>());
        expect(material[900], isA<Color>());
      });

      test('funktioniert mit verschiedenen Farben', () {
        final materials = [
          KidsColors.createMaterialColor(KidsColors.primary),
          KidsColors.createMaterialColor(KidsColors.secondary),
          KidsColors.createMaterialColor(KidsColors.success),
          KidsColors.createMaterialColor(KidsColors.error),
        ];

        for (final material in materials) {
          expect(material, isA<MaterialColor>());
          expect(material[500], isNotNull);
        }
      });
    });
  });
}
