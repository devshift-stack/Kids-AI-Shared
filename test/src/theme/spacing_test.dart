import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_ai_shared/src/theme/spacing.dart';

void main() {
  group('KidsSpacing', () {
    group('Spacing-Konstanten', () {
      test('Werte sind aufsteigend', () {
        expect(KidsSpacing.xxs, lessThan(KidsSpacing.xs));
        expect(KidsSpacing.xs, lessThan(KidsSpacing.sm));
        expect(KidsSpacing.sm, lessThan(KidsSpacing.md));
        expect(KidsSpacing.md, lessThan(KidsSpacing.lg));
        expect(KidsSpacing.lg, lessThan(KidsSpacing.xl));
        expect(KidsSpacing.xl, lessThan(KidsSpacing.xxl));
        expect(KidsSpacing.xxl, lessThan(KidsSpacing.xxxl));
      });

      test('xxs ist 4.0', () {
        expect(KidsSpacing.xxs, equals(4.0));
      });

      test('md ist 16.0 (Standard-Padding)', () {
        expect(KidsSpacing.md, equals(16.0));
      });

      test('xxxl ist 64.0', () {
        expect(KidsSpacing.xxxl, equals(64.0));
      });
    });

    group('BorderRadius-Konstanten', () {
      test('Werte sind aufsteigend', () {
        expect(KidsSpacing.radiusXs, lessThan(KidsSpacing.radiusSm));
        expect(KidsSpacing.radiusSm, lessThan(KidsSpacing.radiusMd));
        expect(KidsSpacing.radiusMd, lessThan(KidsSpacing.radiusLg));
        expect(KidsSpacing.radiusLg, lessThan(KidsSpacing.radiusXl));
        expect(KidsSpacing.radiusXl, lessThan(KidsSpacing.radiusRound));
      });

      test('radiusRound ist 999.0 (komplett rund)', () {
        expect(KidsSpacing.radiusRound, equals(999.0));
      });

      test('BorderRadius-Objekte sind gueltig', () {
        expect(KidsSpacing.borderRadiusXs, isA<BorderRadius>());
        expect(KidsSpacing.borderRadiusSm, isA<BorderRadius>());
        expect(KidsSpacing.borderRadiusMd, isA<BorderRadius>());
        expect(KidsSpacing.borderRadiusLg, isA<BorderRadius>());
        expect(KidsSpacing.borderRadiusXl, isA<BorderRadius>());
        expect(KidsSpacing.borderRadiusRound, isA<BorderRadius>());
      });
    });

    group('Icon Sizes', () {
      test('Werte sind aufsteigend', () {
        expect(KidsSpacing.iconXs, lessThan(KidsSpacing.iconSm));
        expect(KidsSpacing.iconSm, lessThan(KidsSpacing.iconMd));
        expect(KidsSpacing.iconMd, lessThan(KidsSpacing.iconLg));
        expect(KidsSpacing.iconLg, lessThan(KidsSpacing.iconXl));
        expect(KidsSpacing.iconXl, lessThan(KidsSpacing.iconXxl));
      });

      test('iconMd ist 24.0 (Standard-Icon)', () {
        expect(KidsSpacing.iconMd, equals(24.0));
      });
    });

    group('Button Sizes', () {
      test('Werte sind aufsteigend', () {
        expect(KidsSpacing.buttonHeightSm, lessThan(KidsSpacing.buttonHeightMd));
        expect(KidsSpacing.buttonHeightMd, lessThan(KidsSpacing.buttonHeightLg));
        expect(KidsSpacing.buttonHeightLg, lessThan(KidsSpacing.buttonHeightXl));
      });

      test('buttonHeightMd ist 48.0 (Standard-Button)', () {
        expect(KidsSpacing.buttonHeightMd, equals(48.0));
      });
    });

    group('Avatar Sizes', () {
      test('Werte sind aufsteigend', () {
        expect(KidsSpacing.avatarXs, lessThan(KidsSpacing.avatarSm));
        expect(KidsSpacing.avatarSm, lessThan(KidsSpacing.avatarMd));
        expect(KidsSpacing.avatarMd, lessThan(KidsSpacing.avatarLg));
        expect(KidsSpacing.avatarLg, lessThan(KidsSpacing.avatarXl));
      });
    });

    group('EdgeInsets Presets', () {
      test('paddingSm hat korrekte Werte', () {
        expect(KidsSpacing.paddingSm.left, equals(KidsSpacing.sm));
        expect(KidsSpacing.paddingSm.top, equals(KidsSpacing.sm));
        expect(KidsSpacing.paddingSm.right, equals(KidsSpacing.sm));
        expect(KidsSpacing.paddingSm.bottom, equals(KidsSpacing.sm));
      });

      test('paddingMd hat korrekte Werte', () {
        expect(KidsSpacing.paddingMd.left, equals(KidsSpacing.md));
        expect(KidsSpacing.paddingMd.top, equals(KidsSpacing.md));
      });

      test('paddingHorizontalMd hat nur horizontale Werte', () {
        expect(KidsSpacing.paddingHorizontalMd.left, equals(KidsSpacing.md));
        expect(KidsSpacing.paddingHorizontalMd.right, equals(KidsSpacing.md));
        expect(KidsSpacing.paddingHorizontalMd.top, equals(0.0));
        expect(KidsSpacing.paddingHorizontalMd.bottom, equals(0.0));
      });

      test('paddingVerticalMd hat nur vertikale Werte', () {
        expect(KidsSpacing.paddingVerticalMd.top, equals(KidsSpacing.md));
        expect(KidsSpacing.paddingVerticalMd.bottom, equals(KidsSpacing.md));
        expect(KidsSpacing.paddingVerticalMd.left, equals(0.0));
        expect(KidsSpacing.paddingVerticalMd.right, equals(0.0));
      });

      test('screenPadding hat erwartete Werte', () {
        expect(
          KidsSpacing.screenPadding.horizontal,
          equals(KidsSpacing.md * 2),
        );
        expect(
          KidsSpacing.screenPadding.vertical,
          equals(KidsSpacing.lg * 2),
        );
      });

      test('cardPadding ist EdgeInsets.all(md)', () {
        expect(KidsSpacing.cardPadding.left, equals(KidsSpacing.md));
        expect(KidsSpacing.cardPadding.top, equals(KidsSpacing.md));
      });
    });

    group('Gap SizedBoxes', () {
      test('gapSm hat korrekte Dimensionen', () {
        expect(KidsSpacing.gapSm.width, equals(KidsSpacing.sm));
        expect(KidsSpacing.gapSm.height, equals(KidsSpacing.sm));
      });

      test('gapMd hat korrekte Dimensionen', () {
        expect(KidsSpacing.gapMd.width, equals(KidsSpacing.md));
        expect(KidsSpacing.gapMd.height, equals(KidsSpacing.md));
      });

      test('gapHorizontalMd hat nur Breite', () {
        expect(KidsSpacing.gapHorizontalMd.width, equals(KidsSpacing.md));
        expect(KidsSpacing.gapHorizontalMd.height, isNull);
      });

      test('gapVerticalMd hat nur Hoehe', () {
        expect(KidsSpacing.gapVerticalMd.height, equals(KidsSpacing.md));
        expect(KidsSpacing.gapVerticalMd.width, isNull);
      });
    });

    group('Card Sizes', () {
      test('cardMinHeight ist 100.0', () {
        expect(KidsSpacing.cardMinHeight, equals(100.0));
      });

      test('cardMaxWidth ist 400.0', () {
        expect(KidsSpacing.cardMaxWidth, equals(400.0));
      });

      test('gameCardSize ist 150.0', () {
        expect(KidsSpacing.gameCardSize, equals(150.0));
      });
    });
  });
}
