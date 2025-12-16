# Firebase Cloud Functions - Kids AI Train

Push Notifications für die Kids AI Train App-Familie.

## Struktur

```
firebase/
├── firebase.json           # Firebase Konfiguration
├── firestore.rules         # Firestore Sicherheitsregeln
├── firestore.indexes.json  # Firestore Indizes
├── functions/
│   ├── package.json        # Node.js Dependencies
│   └── index.js            # Cloud Functions
└── README.md
```

## Cloud Functions

### 1. `onActivityCreated`
**Trigger:** Neues Dokument in `activity/` Collection

Sendet Notification wenn:
- Kind Session startet (`session_started`)
- Kind Session beendet (`session_ended`)
- Kind Spiel abschließt (`game_completed`)

### 2. `onChildUpdated`
**Trigger:** Dokument in `parents/{parentId}/children/{childId}` geändert

Sendet Notification wenn:
- Neues Gerät verbunden wird
- Gerät getrennt wird

### 3. `dailyReport`
**Trigger:** Scheduled, täglich um 19:00 Uhr (Europe/Berlin)

Sendet tägliche Zusammenfassung an alle Eltern mit aktiviertem `dailyReport`.

### 4. `sendTestNotification`
**Trigger:** HTTP POST Request

Für Tests. Body:
```json
{
  "parentId": "...",
  "title": "Test",
  "body": "Test Nachricht"
}
```

## Sprachen

Alle Notifications werden in der Sprache des Parents gesendet:
- 🇩🇪 Deutsch (de)
- 🇬🇧 English (en)
- 🇹🇷 Türkçe (tr)
- 🇧🇦 Bosanski (bs)
- 🇷🇸 Srpski (sr)
- 🇭🇷 Hrvatski (hr)

## Deployment

### Voraussetzungen

1. Firebase CLI installieren:
```bash
npm install -g firebase-tools
```

2. Bei Firebase anmelden:
```bash
firebase login
```

3. Projekt auswählen:
```bash
firebase use kids-ai-train
```

### Functions deployen

```bash
cd firebase/functions
npm install
cd ..
firebase deploy --only functions
```

### Firestore Rules deployen

```bash
firebase deploy --only firestore:rules
```

### Alles deployen

```bash
firebase deploy
```

## Lokales Testen

```bash
cd firebase
firebase emulators:start
```

Emulator UI: http://localhost:4000

## Notification Settings

Eltern können in ParentsDash einstellen:
- `enabled` - Push Notifications an/aus
- `activityAlerts` - Session/Spiel Notifications
- `dailyReport` - Tägliche Zusammenfassung
- `deviceAlerts` - Geräte-Verbindungen

Diese werden in Firestore gespeichert:
```
/parents/{parentId}
  └── notificationSettings: {
        enabled: true,
        activityAlerts: true,
        dailyReport: false,
        deviceAlerts: true
      }
```

## FCM Tokens

Die Apps speichern FCM Tokens im Parent-Dokument:
```
/parents/{parentId}
  └── fcmTokens: ["token1", "token2", ...]
```

Ungültige Tokens werden automatisch entfernt.

## APNs Setup (iOS)

1. Apple Developer Account → Certificates, IDs & Profiles
2. Keys → Create Key → Enable "Apple Push Notifications service (APNs)"
3. Download `.p8` Datei
4. Firebase Console → Project Settings → Cloud Messaging → iOS
5. APNs Authentication Key hochladen

## Monitoring

```bash
# Logs anzeigen
firebase functions:log

# Live-Logs
firebase functions:log --follow
```
