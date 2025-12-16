/**
 * Kids AI Train - Cloud Functions for Push Notifications
 *
 * Diese Functions senden Push Notifications an Eltern wenn:
 * - Kind eine Session startet/beendet
 * - Kind ein Spiel abschließt
 * - Gerät verbunden/getrennt wird
 * - Tägliche Zusammenfassung (scheduled)
 */

const { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

// Firebase initialisieren
initializeApp();

const db = getFirestore();
const messaging = getMessaging();

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Holt FCM Tokens eines Parents
 */
async function getParentTokens(parentId) {
  const parentDoc = await db.collection("parents").doc(parentId).get();
  if (!parentDoc.exists) return [];

  const data = parentDoc.data();
  return data.fcmTokens || [];
}

/**
 * Holt Notification-Einstellungen eines Parents
 */
async function getNotificationSettings(parentId) {
  const parentDoc = await db.collection("parents").doc(parentId).get();
  if (!parentDoc.exists) {
    return { enabled: true, activityAlerts: true, dailyReport: false, deviceAlerts: true };
  }

  const data = parentDoc.data();
  return data.notificationSettings || {
    enabled: true,
    activityAlerts: true,
    dailyReport: false,
    deviceAlerts: true
  };
}

/**
 * Sendet eine Notification an einen Parent
 */
async function sendNotification(parentId, title, body, data = {}) {
  const settings = await getNotificationSettings(parentId);

  // Prüfe ob Notifications aktiviert sind
  if (!settings.enabled) {
    console.log(`Notifications disabled for parent ${parentId}`);
    return;
  }

  const tokens = await getParentTokens(parentId);
  if (tokens.length === 0) {
    console.log(`No FCM tokens for parent ${parentId}`);
    return;
  }

  const message = {
    notification: { title, body },
    data: { ...data, parentId },
    tokens: tokens
  };

  try {
    const response = await messaging.sendEachForMulticast(message);
    console.log(`Sent ${response.successCount}/${tokens.length} notifications to parent ${parentId}`);

    // Entferne ungültige Tokens
    if (response.failureCount > 0) {
      const invalidTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success && resp.error?.code === "messaging/registration-token-not-registered") {
          invalidTokens.push(tokens[idx]);
        }
      });

      if (invalidTokens.length > 0) {
        await db.collection("parents").doc(parentId).update({
          fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens)
        });
        console.log(`Removed ${invalidTokens.length} invalid tokens`);
      }
    }
  } catch (error) {
    console.error("Error sending notification:", error);
  }
}

/**
 * Übersetzt Notification-Texte basierend auf Sprache
 */
function translate(key, lang, params = {}) {
  const translations = {
    // Aktivitäts-Benachrichtigungen
    "session_started": {
      de: { title: "Lernzeit gestartet", body: "{name} hat angefangen zu lernen" },
      en: { title: "Learning started", body: "{name} started learning" },
      tr: { title: "Öğrenme başladı", body: "{name} öğrenmeye başladı" },
      bs: { title: "Učenje počelo", body: "{name} je počeo/la učiti" },
      sr: { title: "Učenje počelo", body: "{name} je počeo/la da uči" },
      hr: { title: "Učenje započelo", body: "{name} je počeo/la učiti" }
    },
    "session_ended": {
      de: { title: "Lernzeit beendet", body: "{name} hat {minutes} Min gelernt" },
      en: { title: "Learning ended", body: "{name} learned for {minutes} min" },
      tr: { title: "Öğrenme bitti", body: "{name} {minutes} dk öğrendi" },
      bs: { title: "Učenje završeno", body: "{name} je učio/la {minutes} min" },
      sr: { title: "Učenje završeno", body: "{name} je učio/la {minutes} min" },
      hr: { title: "Učenje završeno", body: "{name} je učio/la {minutes} min" }
    },
    "game_completed": {
      de: { title: "Spiel abgeschlossen", body: "{name} hat {game} gespielt - Punkte: {score}" },
      en: { title: "Game completed", body: "{name} played {game} - Score: {score}" },
      tr: { title: "Oyun tamamlandı", body: "{name} {game} oynadı - Puan: {score}" },
      bs: { title: "Igra završena", body: "{name} je igrao/la {game} - Bodovi: {score}" },
      sr: { title: "Igra završena", body: "{name} je igrao/la {game} - Poeni: {score}" },
      hr: { title: "Igra završena", body: "{name} je igrao/la {game} - Bodovi: {score}" }
    },
    // Geräte-Benachrichtigungen
    "device_connected": {
      de: { title: "Gerät verbunden", body: "{name}s Gerät wurde verbunden" },
      en: { title: "Device connected", body: "{name}'s device was connected" },
      tr: { title: "Cihaz bağlandı", body: "{name}'in cihazı bağlandı" },
      bs: { title: "Uređaj povezan", body: "Uređaj od {name} je povezan" },
      sr: { title: "Uređaj povezan", body: "Uređaj od {name} je povezan" },
      hr: { title: "Uređaj povezan", body: "Uređaj od {name} je povezan" }
    },
    "device_disconnected": {
      de: { title: "Gerät getrennt", body: "{name}s Gerät wurde getrennt" },
      en: { title: "Device disconnected", body: "{name}'s device was disconnected" },
      tr: { title: "Cihaz bağlantısı kesildi", body: "{name}'in cihazının bağlantısı kesildi" },
      bs: { title: "Uređaj odvojen", body: "Uređaj od {name} je odvojen" },
      sr: { title: "Uređaj odvojen", body: "Uređaj od {name} je odvojen" },
      hr: { title: "Uređaj odvojen", body: "Uređaj od {name} je odvojen" }
    },
    // Täglicher Bericht
    "daily_report": {
      de: { title: "Täglicher Lernbericht", body: "{name} hat heute {minutes} Minuten gelernt" },
      en: { title: "Daily learning report", body: "{name} learned {minutes} minutes today" },
      tr: { title: "Günlük öğrenme raporu", body: "{name} bugün {minutes} dakika öğrendi" },
      bs: { title: "Dnevni izvještaj", body: "{name} je danas učio/la {minutes} minuta" },
      sr: { title: "Dnevni izveštaj", body: "{name} je danas učio/la {minutes} minuta" },
      hr: { title: "Dnevno izvješće", body: "{name} je danas učio/la {minutes} minuta" }
    }
  };

  const langTexts = translations[key]?.[lang] || translations[key]?.["de"] || { title: key, body: "" };

  let title = langTexts.title;
  let body = langTexts.body;

  // Parameter ersetzen
  Object.keys(params).forEach(param => {
    title = title.replace(`{${param}}`, params[param]);
    body = body.replace(`{${param}}`, params[param]);
  });

  return { title, body };
}

// ============================================
// CLOUD FUNCTIONS
// ============================================

/**
 * Trigger: Neue Aktivität erstellt
 * Sendet Notification bei Session-Start/Ende und Spiel-Abschluss
 */
exports.onActivityCreated = onDocumentCreated(
  "activity/{activityId}",
  async (event) => {
    const activity = event.data?.data();
    if (!activity) return;

    const { parentId, childId, type, gameId, score, duration } = activity;

    // Hole Child-Info
    const childDoc = await db.collection("parents").doc(parentId)
      .collection("children").doc(childId).get();

    if (!childDoc.exists) return;

    const child = childDoc.data();
    const childName = child.name || "Kind";

    // Hole Parent-Sprache
    const parentDoc = await db.collection("parents").doc(parentId).get();
    const lang = parentDoc.data()?.language || "de";

    // Prüfe Notification-Einstellungen
    const settings = await getNotificationSettings(parentId);

    let notificationKey = null;
    let params = { name: childName };

    switch (type) {
      case "session_started":
        if (settings.activityAlerts) notificationKey = "session_started";
        break;

      case "session_ended":
        if (settings.activityAlerts) {
          notificationKey = "session_ended";
          params.minutes = Math.round((duration || 0) / 60);
        }
        break;

      case "game_completed":
        if (settings.activityAlerts) {
          notificationKey = "game_completed";
          params.game = gameId || "Spiel";
          params.score = score || 0;
        }
        break;
    }

    if (notificationKey) {
      const { title, body } = translate(notificationKey, lang, params);
      await sendNotification(parentId, title, body, {
        type: type,
        childId: childId
      });
    }
  }
);

/**
 * Trigger: Kind-Dokument aktualisiert
 * Erkennt Geräte-Verbindung/-Trennung
 */
exports.onChildUpdated = onDocumentUpdated(
  "parents/{parentId}/children/{childId}",
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();

    if (!before || !after) return;

    const parentId = event.params.parentId;
    const childName = after.name || "Kind";

    // Prüfe Notification-Einstellungen
    const settings = await getNotificationSettings(parentId);
    if (!settings.deviceAlerts) return;

    // Hole Parent-Sprache
    const parentDoc = await db.collection("parents").doc(parentId).get();
    const lang = parentDoc.data()?.language || "de";

    const beforeDevices = before.linkedDeviceIds || [];
    const afterDevices = after.linkedDeviceIds || [];

    // Neues Gerät verbunden
    if (afterDevices.length > beforeDevices.length) {
      const { title, body } = translate("device_connected", lang, { name: childName });
      await sendNotification(parentId, title, body, {
        type: "device_connected",
        childId: event.params.childId
      });
    }

    // Gerät getrennt
    if (afterDevices.length < beforeDevices.length) {
      const { title, body } = translate("device_disconnected", lang, { name: childName });
      await sendNotification(parentId, title, body, {
        type: "device_disconnected",
        childId: event.params.childId
      });
    }
  }
);

/**
 * Scheduled: Täglicher Bericht um 19:00 Uhr
 */
exports.dailyReport = onSchedule(
  {
    schedule: "0 19 * * *",  // Jeden Tag um 19:00
    timeZone: "Europe/Berlin"
  },
  async (event) => {
    console.log("Running daily report...");

    // Hole alle Parents mit aktiviertem Daily Report
    const parentsSnapshot = await db.collection("parents")
      .where("notificationSettings.dailyReport", "==", true)
      .get();

    for (const parentDoc of parentsSnapshot.docs) {
      const parentId = parentDoc.id;
      const parentData = parentDoc.data();
      const lang = parentData.language || "de";

      // Hole alle Kinder
      const childrenSnapshot = await db.collection("parents").doc(parentId)
        .collection("children").get();

      for (const childDoc of childrenSnapshot.docs) {
        const childId = childDoc.id;
        const childData = childDoc.data();
        const childName = childData.name || "Kind";

        // Berechne Lernzeit heute
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const activitiesSnapshot = await db.collection("activity")
          .where("parentId", "==", parentId)
          .where("childId", "==", childId)
          .where("timestamp", ">=", today)
          .get();

        let totalMinutes = 0;
        activitiesSnapshot.docs.forEach(doc => {
          const data = doc.data();
          if (data.duration) {
            totalMinutes += Math.round(data.duration / 60);
          }
        });

        if (totalMinutes > 0) {
          const { title, body } = translate("daily_report", lang, {
            name: childName,
            minutes: totalMinutes
          });

          await sendNotification(parentId, title, body, {
            type: "daily_report",
            childId: childId
          });
        }
      }
    }

    console.log("Daily report completed");
  }
);

/**
 * HTTP Function: Manuell Notification senden (für Tests)
 */
exports.sendTestNotification = require("firebase-functions/v2/https").onRequest(
  async (req, res) => {
    // Nur für autorisierte Anfragen
    if (req.method !== "POST") {
      res.status(405).send("Method not allowed");
      return;
    }

    const { parentId, title, body } = req.body;

    if (!parentId || !title || !body) {
      res.status(400).send("Missing parentId, title, or body");
      return;
    }

    await sendNotification(parentId, title, body, { type: "test" });
    res.status(200).send("Notification sent");
  }
);
