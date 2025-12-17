# Test Prompts für Kids-AI-Shared

Generiert vom Lianko-Agent für konsistente Unit Tests über alle Repos.

---

## 1. Theme (Design System)

### 1.1 KidsColors

**Datei:** `lib/src/theme/colors.dart`
**Speichern in:** `test/src/theme/colors_test.dart`
**Beschreibung:** Farbpalette für alle Kids AI Apps

#### Klassen zu testen:
1. `KidsColors`
   - Alle statischen Farbkonstanten
   - `randomAvatarColor()` - Zufällige Avatar-Farbe
   - `avatarColorAt()` - Avatar-Farbe nach Index
   - `createMaterialColor()` - MaterialColor aus Color

#### Zu testende Szenarien:
- [ ] Alle Primary Colors sind gültige Color-Objekte
- [ ] Alle Feedback Colors sind gültige Color-Objekte
- [ ] avatarColors Liste hat 8 Farben
- [ ] avatarColorAt() gibt korrekte Farbe für Index
- [ ] avatarColorAt() wrapped bei Index > 7
- [ ] randomAvatarColor() gibt Farbe aus avatarColors
- [ ] createMaterialColor() erstellt gültige MaterialColor

#### Edge Cases:
- avatarColorAt mit negativem Index
- avatarColorAt mit sehr großem Index

#### Beispiel-Test:
```dart
test('Alle Primary Colors sind gültige Color-Objekte', () {
  expect(KidsColors.primary, isA<Color>());
  expect(KidsColors.primaryLight, isA<Color>());
  expect(KidsColors.primaryDark, isA<Color>());
});

test('avatarColorAt() wrapped bei Index > 7', () {
  expect(KidsColors.avatarColorAt(0), equals(KidsColors.avatarColorAt(8)));
  expect(KidsColors.avatarColorAt(1), equals(KidsColors.avatarColorAt(9)));
});

test('createMaterialColor() erstellt gültige MaterialColor', () {
  final material = KidsColors.createMaterialColor(KidsColors.primary);
  expect(material, isA<MaterialColor>());
  expect(material[500], isNotNull);
});
```

#### Abhängigkeiten: Keine (pure Dart/Flutter)

---

### 1.2 KidsSpacing

**Datei:** `lib/src/theme/spacing.dart`
**Speichern in:** `test/src/theme/spacing_test.dart`
**Beschreibung:** Abstände und Größen für konsistentes Layout

#### Klassen zu testen:
1. `KidsSpacing`
   - Spacing-Konstanten (xxs bis xxxl)
   - BorderRadius-Konstanten
   - Icon Sizes
   - Button Sizes
   - Avatar Sizes
   - EdgeInsets Presets
   - Gap SizedBox Presets

#### Zu testende Szenarien:
- [ ] Spacing-Werte sind aufsteigend (xxs < xs < sm...)
- [ ] BorderRadius-Objekte sind korrekt konfiguriert
- [ ] Gap SizedBox haben korrekte Dimensionen
- [ ] screenPadding hat erwartete Werte

#### Beispiel-Test:
```dart
test('Spacing-Werte sind aufsteigend', () {
  expect(KidsSpacing.xxs, lessThan(KidsSpacing.xs));
  expect(KidsSpacing.xs, lessThan(KidsSpacing.sm));
  expect(KidsSpacing.sm, lessThan(KidsSpacing.md));
  expect(KidsSpacing.md, lessThan(KidsSpacing.lg));
  expect(KidsSpacing.lg, lessThan(KidsSpacing.xl));
});

test('Gap SizedBox haben korrekte Dimensionen', () {
  expect(KidsSpacing.gapSm.width, equals(KidsSpacing.sm));
  expect(KidsSpacing.gapSm.height, equals(KidsSpacing.sm));
});
```

#### Abhängigkeiten: Keine

---

## 2. Audio

### 2.1 TtsConfig

**Datei:** `lib/src/audio/tts_config.dart`
**Speichern in:** `test/src/audio/tts_config_test.dart`
**Beschreibung:** TTS-Konfiguration mit Stimmen und Phrasen

#### Klassen zu testen:
1. `TtsConfig`
   - `voices` Map - Hauptstimmen pro Sprache
   - `childVoices` Map - Kinderstimmen
   - `commonPhrases` Map - Häufige Phrasen pro Sprache
   - `getVoiceForChild()` - Beste Stimme für Kind
   - `supportedLanguages` - Liste der Sprachen
   - `isLanguageSupported()` - Prüft Sprachunterstützung

2. `TtsVoiceConfig`
   - Alle Felder sind gesetzt

#### Zu testende Szenarien:
- [ ] voices enthält alle erwarteten Sprachen (bs-BA, de-DE, en-US, hr-HR, sr-RS, tr-TR)
- [ ] getVoiceForChild gibt childVoice für age <= 6
- [ ] getVoiceForChild gibt normale voice für age > 6
- [ ] getVoiceForChild gibt fallback für unbekannte Sprache
- [ ] commonPhrases hat Einträge für alle Sprachen
- [ ] isLanguageSupported gibt true für unterstützte Sprache
- [ ] isLanguageSupported gibt false für nicht-unterstützte

#### Edge Cases:
- getVoiceForChild mit age = 0
- getVoiceForChild mit Sprache ohne childVoice
- Leere commonPhrases für Sprache

#### Beispiel-Test:
```dart
test('getVoiceForChild gibt childVoice für age <= 6', () {
  final voice = TtsConfig.getVoiceForChild('de-DE', 5);
  expect(voice.displayName, contains('Kind'));
});

test('getVoiceForChild gibt normale voice für age > 6', () {
  final voice = TtsConfig.getVoiceForChild('de-DE', 10);
  expect(voice.displayName, equals('Katja (Deutsch)'));
});

test('isLanguageSupported prüft korrekt', () {
  expect(TtsConfig.isLanguageSupported('de-DE'), isTrue);
  expect(TtsConfig.isLanguageSupported('fr-FR'), isFalse);
});
```

#### Abhängigkeiten: Keine

---

## 3. Sync

### 3.1 OfflineSyncService

**Datei:** `lib/src/sync/offline_sync_service.dart`
**Speichern in:** `test/src/sync/offline_sync_service_test.dart`
**Beschreibung:** Offline-Sync und Caching Service

#### Klassen zu testen:
1. `SyncAction`
   - `fromMap()` / `toMap()`
   - Static constants (create, update, delete)

2. `CacheEntry`
   - `fromMap()` / `toMap()`

3. `OfflineSyncService`
   - `initialize()` - Lädt pending actions
   - `setOnlineStatus()` - Setzt Online-Status
   - `queueAction()` - Fügt Aktion zur Queue
   - `syncPendingActions()` - Synchronisiert ausstehende
   - `cacheData()` - Speichert Daten im Cache
   - `getCachedData()` - Holt gecachte Daten
   - `isCacheValid()` - Prüft Cache-Gültigkeit
   - `getWithCache()` - Holt mit Cache-Fallback
   - `clearCache()` - Löscht Cache

#### Zu testende Szenarien:
- [ ] SyncAction Roundtrip (toMap/fromMap)
- [ ] CacheEntry Roundtrip
- [ ] queueAction fügt Action zu pendingActions
- [ ] setOnlineStatus(true) triggert sync wenn vorher offline
- [ ] isCacheValid gibt false bei abgelaufenem Cache
- [ ] getWithCache nutzt Cache wenn offline
- [ ] getWithCache fetcht neu wenn online und Cache abgelaufen
- [ ] clearCache entfernt alle cache_ Einträge

#### Edge Cases:
- Leere pending actions Liste
- Sync während bereits Sync läuft
- Cache mit maxAge = 0
- onSyncAction callback nicht gesetzt

#### Beispiel-Test:
```dart
test('SyncAction Roundtrip', () {
  final action = SyncAction(
    type: SyncAction.create,
    collection: 'users',
    documentId: 'doc-123',
    data: {'name': 'Test'},
  );
  final map = action.toMap();
  final restored = SyncAction.fromMap(map);
  expect(restored.type, equals(action.type));
  expect(restored.collection, equals(action.collection));
  expect(restored.documentId, equals(action.documentId));
});

test('isCacheValid gibt false bei abgelaufenem Cache', () async {
  final service = OfflineSyncService();
  await service.initialize();
  await service.cacheData('test', {'value': 1});

  // Mit sehr kurzer maxAge sollte Cache sofort ungültig sein
  expect(service.isCacheValid('test', maxAge: Duration.zero), isFalse);
});
```

#### Abhängigkeiten:
- Mock für SharedPreferences

---

## 4. Widgets (Widget Tests)

### 4.1 KidButton

**Datei:** `lib/src/widgets/kid_button.dart`
**Speichern in:** `test/src/widgets/kid_button_test.dart`
**Beschreibung:** Kindgerechter Button

#### Widget Tests:
- [ ] Button rendert mit korrektem Text
- [ ] onPressed wird aufgerufen bei Tap
- [ ] Button ist disabled wenn onPressed null

---

### 4.2 KidCard

**Datei:** `lib/src/widgets/kid_card.dart`
**Speichern in:** `test/src/widgets/kid_card_test.dart`
**Beschreibung:** Kindgerechte Card-Komponente

#### Widget Tests:
- [ ] Card rendert child Widget
- [ ] Card hat korrekte Rundung

---

### 4.3 KidAvatar

**Datei:** `lib/src/widgets/kid_avatar.dart`
**Speichern in:** `test/src/widgets/kid_avatar_test.dart`
**Beschreibung:** Avatar-Anzeige für Kinder

#### Widget Tests:
- [ ] Avatar zeigt Bild wenn URL vorhanden
- [ ] Avatar zeigt Initialen wenn kein Bild
- [ ] Avatar nutzt korrekte Größe

---

## Zusammenfassung

| Modul | Priorität | Komplexität |
|-------|-----------|-------------|
| KidsColors | Hoch | Niedrig |
| KidsSpacing | Mittel | Niedrig |
| TtsConfig | Hoch | Niedrig |
| OfflineSyncService | Hoch | Mittel |
| Widget Tests | Niedrig | Mittel |

---

## Hinweise für Tests

### Keine externen Abhängigkeiten
Das Shared-Package ist größtenteils pure Dart/Flutter ohne externe Services. Die meisten Tests benötigen keine Mocks.

### Widget Tests
Für Widget Tests in Flutter:
```dart
testWidgets('Button rendert korrekt', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: KidButton(
      text: 'Test',
      onPressed: () {},
    ),
  ));
  expect(find.text('Test'), findsOneWidget);
});
```
