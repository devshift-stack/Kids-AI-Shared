# Firebase Setup - Kids AI Train

**Letzte Aktualisierung:** 2025-12-16

---

## WICHTIG: EIN Firebase-Projekt für ALLE Apps

```
Firebase Projekt: "kids-ai-train"
├── ParentsDash (iOS + Android + Web)
├── Alanko App (iOS + Android)
└── Lianko App (iOS + Android)
```

---

## 1. Firebase-Projekt erstellen (EINMALIG - bereits erledigt wenn Projekt existiert)

### Schritt 1: Firebase Console öffnen
```
https://console.firebase.google.com/
```

### Schritt 2: Neues Projekt erstellen
- Klick: "Projekt hinzufügen"
- Name: `kids-ai-train`
- Google Analytics: Optional (empfohlen: Ja)
- Warten bis Projekt erstellt ist

---

## 2. Apps registrieren

### Für jeden Agent: App in Firebase registrieren

#### ParentsDash Agent:
1. Firebase Console → Projekt `kids-ai-train`
2. Klick: "App hinzufügen"
3. Plattformen:
   - Android: `com.devshift.kidsai.parent`
   - iOS: `com.devshift.kidsai.parent`
   - Web: `Kids AI Parent Dashboard`

#### Alanko Agent:
1. Firebase Console → Projekt `kids-ai-train`
2. Klick: "App hinzufügen"
3. Plattformen:
   - Android: `com.devshift.kidsai.alanko`
   - iOS: `com.devshift.kidsai.alanko`

#### Lianko Agent:
1. Firebase Console → Projekt `kids-ai-train`
2. Klick: "App hinzufügen"
3. Plattformen:
   - Android: `com.devshift.kidsai.lianko`
   - iOS: `com.devshift.kidsai.lianko`

---

## 3. Konfigurationsdateien herunterladen

### Android (für jede App):
1. Firebase Console → Projekteinstellungen → Deine Apps
2. Android-App auswählen
3. `google-services.json` herunterladen
4. Datei in `android/app/` ablegen

### iOS (für jede App):
1. Firebase Console → Projekteinstellungen → Deine Apps
2. iOS-App auswählen
3. `GoogleService-Info.plist` herunterladen
4. Datei in `ios/Runner/` ablegen

### Web (nur ParentsDash):
1. Firebase Console → Projekteinstellungen → Deine Apps
2. Web-App auswählen
3. Firebase-Konfiguration kopieren
4. In `lib/firebase_options.dart` einfügen

---

## 4. Firebase Services aktivieren

### Authentication:
1. Firebase Console → Authentication → Erste Schritte
2. Anmeldemethoden aktivieren:
   - ✅ E-Mail/Passwort (für Eltern)
   - ✅ Anonym (für Kinder-Apps)

### Firestore Database:
1. Firebase Console → Firestore Database → Datenbank erstellen
2. Modus: **Produktionsmodus**
3. Standort: `europe-west3` (Frankfurt)

---

## 5. Firestore Sicherheitsregeln

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Parents Collection
    match /parents/{parentId} {
      // Nur der Parent selbst oder verknüpfte Co-Parents können lesen/schreiben
      allow read, write: if request.auth != null &&
        (request.auth.uid == parentId ||
         resource.data.coParents[request.auth.uid] == true);

      // Children Sub-Collection
      match /children/{childId} {
        allow read, write: if request.auth != null &&
          (request.auth.uid == parentId ||
           get(/databases/$(database)/documents/parents/$(parentId)).data.coParents[request.auth.uid] == true);
      }
    }

    // Parent Codes - für Kinder-App Verknüpfung
    // Kinder-Apps können Codes validieren (anonym)
    match /parents/{parentId}/children/{childId} {
      allow read: if request.auth != null &&
        resource.data.parentCode != null;
    }

    // Children Activity Logs - Kinder-Apps schreiben hier
    match /activity/{activityId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 6. Firestore Datenstruktur

```
/parents/{parentId}
├── email: "vater@example.com"
├── createdAt: timestamp
├── coParents: {                    ← Verknüpfte Elternteile
│     "mutterUserId": true
│   }
├── coParentCode: "XYZ123"          ← Code für Elternteil-Einladung
├── coParentCodeExpiresAt: timestamp
│
└── /children/{childId}
    ├── name: "Max"
    ├── age: 8
    ├── parentCode: "K3M7XP"        ← Code für Kind-App
    ├── parentCodeExpiresAt: timestamp
    ├── isLinked: true
    ├── linkedDeviceIds: ["device1", "device2"]
    ├── timeLimit: {...}
    ├── leaderboardConsent: {...}
    ├── accessibilitySettings: {
    │     subtitlesEnabled: false,
    │     subtitleLanguage: "de"
    │   }
    └── gameSettings: {...}

/activity/{activityId}
├── childId: "child123"
├── parentId: "parent456"
├── type: "game_completed"
├── gameId: "math_basics"
├── score: 85
├── duration: 300
├── timestamp: timestamp
```

---

## 7. Flutter-Konfiguration

### pubspec.yaml (alle Apps):
```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.6.1
```

### main.dart (alle Apps):
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

---

## 8. FlutterFire CLI (empfohlen)

Automatische Konfiguration für alle Plattformen:

```bash
# FlutterFire CLI installieren
dart pub global activate flutterfire_cli

# Im App-Ordner ausführen
flutterfire configure --project=kids-ai-train
```

Dies erstellt automatisch:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

---

## 9. Agent-spezifische Aufgaben

### ParentsDash Agent:
- [ ] Firebase für Web + iOS + Android konfigurieren
- [ ] E-Mail/Passwort Auth implementieren
- [ ] Parent-Dokument bei Registrierung erstellen
- [ ] Children CRUD implementieren
- [ ] Co-Parent Einladung implementieren

### Alanko Agent:
- [ ] Firebase für iOS + Android konfigurieren
- [ ] Anonymous Auth implementieren
- [ ] ParentCode-Validierung implementieren
- [ ] Activity-Logging implementieren
- [ ] Einstellungen von Firestore lesen

### Lianko Agent:
- [ ] Firebase für iOS + Android konfigurieren
- [ ] Anonymous Auth implementieren
- [ ] ParentCode-Validierung implementieren
- [ ] Activity-Logging implementieren
- [ ] Einstellungen von Firestore lesen

---

## 10. Wichtige Hinweise

### NIEMALS:
- ❌ Firebase API-Keys in öffentlichen Repos commiten
- ❌ `google-services.json` / `GoogleService-Info.plist` in Git pushen
- ❌ Firestore-Regeln auf "allow read, write: if true" setzen

### IMMER:
- ✅ `.gitignore` prüfen (Config-Dateien ausschließen)
- ✅ Sicherheitsregeln testen
- ✅ Offline-Persistenz aktivieren für Kinder-Apps

---

## 11. Test-Checkliste

| Test | ParentsDash | Alanko | Lianko |
|------|-------------|--------|--------|
| Firebase initialisiert | [ ] | [ ] | [ ] |
| Auth funktioniert | [ ] | [ ] | [ ] |
| Firestore lesen | [ ] | [ ] | [ ] |
| Firestore schreiben | [ ] | [ ] | [ ] |
| Echtzeit-Sync | [ ] | [ ] | [ ] |

---

**Bei Fragen: Issue auf GitHub erstellen oder User fragen.**
