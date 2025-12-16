# Dashboard Integration Guide

Anleitung für alle Module (Alanko, Lianko, Shared) zur Verbindung mit dem ParentsDash.

---

## Übersicht

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    Alanko       │     │    Lianko       │     │  ParentsDash    │
│   (Kids App)    │     │   (Kids App)    │     │  (Eltern App)   │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │   Firebase Firestore    │
                    │   (Echtzeit-Sync)       │
                    └─────────────────────────┘
```

---

## 1. Firebase Setup (Shared)

### Dependencies hinzufügen

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  cloud_firestore: ^4.14.0
  firebase_auth: ^4.16.0
```

### Firebase initialisieren

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

---

## 2. ParentCode Verbindung (Kids Apps)

### Service erstellen

```dart
// lib/services/parent_link_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParentLinkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Verbindet Kind mit ParentCode
  Future<LinkResult> linkWithParentCode(String code) async {
    final normalizedCode = code.toUpperCase().replaceAll(' ', '');

    // 1. Suche Kind mit diesem Code
    final query = await _firestore
        .collection('children')
        .where('parentCode', isEqualTo: normalizedCode)
        .where('parentCodeExpiresAt', isGreaterThan: Timestamp.now())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return LinkResult.invalid('Code ungültig oder abgelaufen');
    }

    final childDoc = query.docs.first;
    final childId = childDoc.id;

    // 2. Anonymous Auth für Gerät
    UserCredential? userCred;
    if (_auth.currentUser == null) {
      userCred = await _auth.signInAnonymously();
    }
    final deviceId = _auth.currentUser!.uid;

    // 3. Gerät zum Kind hinzufügen
    await _firestore.collection('children').doc(childId).update({
      'isLinked': true,
      'linkedDeviceIds': FieldValue.arrayUnion([deviceId]),
    });

    // 4. Lokal speichern
    await _saveChildIdLocally(childId);

    return LinkResult.success(childId: childId);
  }

  /// Holt Child-ID aus lokalem Speicher
  Future<String?> getLinkedChildId() async {
    // SharedPreferences oder SecureStorage
    // return prefs.getString('linked_child_id');
  }

  Future<void> _saveChildIdLocally(String childId) async {
    // SharedPreferences oder SecureStorage
    // await prefs.setString('linked_child_id', childId);
  }
}

class LinkResult {
  final bool isSuccess;
  final String? childId;
  final String? errorMessage;

  LinkResult.success({required this.childId})
      : isSuccess = true,
        errorMessage = null;

  LinkResult.invalid(this.errorMessage)
      : isSuccess = false,
        childId = null;
}
```

### UI für Code-Eingabe

```dart
// lib/screens/parent_code_screen.dart
class ParentCodeScreen extends StatefulWidget {
  @override
  _ParentCodeScreenState createState() => _ParentCodeScreenState();
}

class _ParentCodeScreenState extends State<ParentCodeScreen> {
  final _controller = TextEditingController();
  final _service = ParentLinkService();
  bool _isLoading = false;

  Future<void> _submitCode() async {
    setState(() => _isLoading = true);

    final result = await _service.linkWithParentCode(_controller.text);

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // Weiter zur App
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Fehler anzeigen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Fehler')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Gib den Code von Mama oder Papa ein:'),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, letterSpacing: 8),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitCode,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Verbinden'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 3. Einstellungen lesen (Kids Apps)

### ChildSettings Provider

```dart
// lib/providers/child_settings_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream der Kind-Einstellungen (Echtzeit-Sync)
final childSettingsProvider = StreamProvider<ChildSettings?>((ref) {
  final childId = ref.watch(linkedChildIdProvider);
  if (childId == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('children')
      .doc(childId)
      .snapshots()
      .map((doc) => doc.exists ? ChildSettings.fromFirestore(doc) : null);
});

/// Linked Child ID (aus lokalem Speicher)
final linkedChildIdProvider = StateProvider<String?>((ref) => null);
```

### ChildSettings Model

```dart
// lib/models/child_settings.dart
class ChildSettings {
  final String id;
  final String name;
  final int age;
  final TimeLimit timeLimit;
  final GameSettings gameSettings;
  final AccessibilitySettings accessibility;

  ChildSettings({
    required this.id,
    required this.name,
    required this.age,
    required this.timeLimit,
    required this.gameSettings,
    required this.accessibility,
  });

  factory ChildSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChildSettings(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      timeLimit: TimeLimit.fromMap(data['timeLimit'] ?? {}),
      gameSettings: _parseGameSettings(data['gameSettings']),
      accessibility: AccessibilitySettings.fromMap(data['accessibilitySettings'] ?? {}),
    );
  }

  static Map<String, GameSetting> _parseGameSettings(dynamic data) {
    if (data == null) return {};
    final map = data as Map<String, dynamic>;
    return map.map((key, value) => MapEntry(key, GameSetting.fromMap(value)));
  }
}
```

---

## 4. Spiele-Zugriff prüfen (Kids Apps)

### GameAccess Service

```dart
// lib/services/game_access_service.dart
class GameAccessService {
  /// Prüft ob Spiel für Kind aktiviert ist
  bool isGameEnabled(ChildSettings? settings, String gameId) {
    if (settings == null) return true; // Kein Link = alles erlaubt

    final gameSetting = settings.gameSettings[gameId];
    return gameSetting?.isEnabled ?? true; // Default: aktiviert
  }

  /// Filtert verfügbare Spiele
  List<GameItem> getAvailableGames(ChildSettings? settings, List<GameItem> allGames) {
    return allGames.where((game) => isGameEnabled(settings, game.id)).toList();
  }
}
```

### In HomeScreen verwenden

```dart
// lib/screens/home/home_screen.dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(childSettingsProvider);
    final gameAccess = GameAccessService();

    return settingsAsync.when(
      data: (settings) {
        final availableGames = gameAccess.getAvailableGames(settings, allGames);

        return GridView.builder(
          itemCount: availableGames.length,
          itemBuilder: (context, index) {
            final game = availableGames[index];
            return GameCard(game: game);
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text('Fehler: $e'),
    );
  }
}
```

---

## 5. Zeitlimits prüfen (Kids Apps)

### TimeLimit Service

```dart
// lib/services/time_limit_service.dart
class TimeLimitService {
  /// Prüft ob Kind noch spielen darf
  Future<TimeLimitStatus> checkTimeLimit(ChildSettings? settings) async {
    if (settings == null) return TimeLimitStatus.allowed();

    final timeLimit = settings.timeLimit;
    final todayMinutes = await _getTodayPlayTime(settings.id);

    // Tägliches Limit erreicht?
    if (todayMinutes >= timeLimit.dailyMinutes) {
      return TimeLimitStatus.limitReached(
        message: 'Du hast heute schon ${timeLimit.dailyMinutes} Minuten gespielt!',
      );
    }

    // Schlafenszeit?
    if (timeLimit.bedtimeEnabled && _isDuringBedtime(timeLimit)) {
      return TimeLimitStatus.bedtime(
        message: 'Es ist Schlafenszeit! Bis morgen!',
      );
    }

    // Pause nötig?
    final sessionMinutes = await _getCurrentSessionTime();
    if (sessionMinutes >= timeLimit.breakIntervalMinutes) {
      return TimeLimitStatus.breakNeeded(
        breakMinutes: timeLimit.breakDurationMinutes,
        message: 'Zeit für eine Pause!',
      );
    }

    return TimeLimitStatus.allowed(
      remainingMinutes: timeLimit.dailyMinutes - todayMinutes,
    );
  }

  bool _isDuringBedtime(TimeLimit timeLimit) {
    final now = TimeOfDay.now();
    // Logik für Schlafenszeit-Check
    return false;
  }

  Future<int> _getTodayPlayTime(String childId) async {
    // Aus Firestore oder lokal lesen
    return 0;
  }

  Future<int> _getCurrentSessionTime() async {
    // Session-Timer
    return 0;
  }
}

class TimeLimitStatus {
  final bool canPlay;
  final String? message;
  final int? remainingMinutes;
  final int? breakMinutes;
  final TimeLimitReason reason;

  TimeLimitStatus._({
    required this.canPlay,
    required this.reason,
    this.message,
    this.remainingMinutes,
    this.breakMinutes,
  });

  factory TimeLimitStatus.allowed({int? remainingMinutes}) => TimeLimitStatus._(
    canPlay: true,
    reason: TimeLimitReason.allowed,
    remainingMinutes: remainingMinutes,
  );

  factory TimeLimitStatus.limitReached({required String message}) => TimeLimitStatus._(
    canPlay: false,
    reason: TimeLimitReason.dailyLimitReached,
    message: message,
  );

  factory TimeLimitStatus.bedtime({required String message}) => TimeLimitStatus._(
    canPlay: false,
    reason: TimeLimitReason.bedtime,
    message: message,
  );

  factory TimeLimitStatus.breakNeeded({required int breakMinutes, required String message}) => TimeLimitStatus._(
    canPlay: false,
    reason: TimeLimitReason.breakNeeded,
    message: message,
    breakMinutes: breakMinutes,
  );
}

enum TimeLimitReason {
  allowed,
  dailyLimitReached,
  bedtime,
  breakNeeded,
}
```

---

## 6. Untertitel-Einstellungen (Kids Apps)

### Untertitel lesen

```dart
// lib/services/subtitle_service.dart
class SubtitleService {
  /// Prüft ob Untertitel aktiviert sind
  bool areSubtitlesEnabled(ChildSettings? settings) {
    if (settings == null) return false; // Default: aus
    return settings.accessibility.subtitlesEnabled;
  }

  /// Holt Untertitel-Sprache
  String getSubtitleLanguage(ChildSettings? settings) {
    if (settings == null) return 'de'; // Default: Deutsch
    return settings.accessibility.subtitleLanguage;
  }
}
```

### In Spiel verwenden

```dart
// In einem Spiel-Widget
class GameWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(childSettingsProvider).value;
    final subtitleService = SubtitleService();

    final showSubtitles = subtitleService.areSubtitlesEnabled(settings);
    final subtitleLang = subtitleService.getSubtitleLanguage(settings);

    return Column(
      children: [
        // Spiel-Content
        GameContent(),

        // Untertitel (wenn aktiviert)
        if (showSubtitles)
          SubtitleOverlay(
            text: _getCurrentText(),
            language: subtitleLang,
          ),
      ],
    );
  }
}
```

---

## 7. Firestore Struktur

```
firestore/
├── parents/
│   └── {parentId}/
│       ├── email: string
│       ├── coParents: map<string, bool>
│       ├── coParentCode: string?
│       └── coParentCodeExpiresAt: timestamp?
│
└── children/
    └── {childId}/
        ├── parentId: string
        ├── name: string
        ├── age: number
        ├── parentCode: string
        ├── parentCodeExpiresAt: timestamp
        ├── isLinked: boolean
        ├── linkedDeviceIds: string[]
        │
        ├── timeLimit/
        │   ├── dailyMinutes: number (default: 60)
        │   ├── breakIntervalMinutes: number (default: 30)
        │   ├── breakDurationMinutes: number (default: 5)
        │   ├── bedtimeEnabled: boolean
        │   ├── bedtimeStart: string (HH:mm)
        │   └── bedtimeEnd: string (HH:mm)
        │
        ├── gameSettings/
        │   ├── letters/
        │   │   └── isEnabled: boolean (default: true)
        │   ├── numbers/
        │   │   └── isEnabled: boolean (default: true)
        │   ├── colors/
        │   │   └── isEnabled: boolean (default: true)
        │   ├── shapes/
        │   │   └── isEnabled: boolean (default: true)
        │   ├── animals/
        │   │   └── isEnabled: boolean (default: true)
        │   ├── stories/
        │   │   └── isEnabled: boolean (default: true)
        │   └── quiz/
        │       └── isEnabled: boolean (default: true)
        │
        ├── accessibilitySettings/
        │   ├── subtitlesEnabled: boolean (default: false)
        │   └── subtitleLanguage: string (default: 'de')
        │
        └── leaderboardConsent/
            ├── canSeeLeaderboard: boolean
            ├── canBeOnLeaderboard: boolean
            └── displayNameType: string
```

---

## 8. Echtzeit-Sync

Alle Einstellungen werden automatisch synchronisiert durch Firestore Streams:

```dart
// Einstellungen ändern sich automatisch wenn Eltern sie im Dashboard ändern
ref.watch(childSettingsProvider).when(
  data: (settings) {
    // UI aktualisiert sich automatisch
    // Spiele werden ein/ausgeblendet
    // Untertitel werden aktiviert/deaktiviert
    // Zeitlimits werden angepasst
  },
);
```

---

## Zusammenfassung

| Feature | ParentsDash | Kids Apps |
|---------|-------------|-----------|
| ParentCode erstellen | ✅ Erstellt Code | - |
| ParentCode eingeben | - | ✅ Verbindet Kind |
| Spiele verwalten | ✅ Ein/Ausschalten | ✅ Liest & filtert |
| Zeitlimits | ✅ Konfiguriert | ✅ Prüft & blockiert |
| Untertitel | ✅ Aktiviert + Sprache | ✅ Zeigt an |
| Co-Parent | ✅ Einladen/Verknüpfen | - |

Alle Änderungen im ParentsDash werden in **Echtzeit** an die Kids Apps übertragen.
