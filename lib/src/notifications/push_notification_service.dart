import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Push-Benachrichtigungen für Kids AI Apps
/// Unterstützt Firebase Cloud Messaging und lokale Benachrichtigungen

/// Benachrichtigungs-Typen
enum NotificationType {
  /// Erinnerung zum Spielen/Lernen
  reminder,

  /// Neuer Inhalt verfügbar
  newContent,

  /// Belohnung/Achievement
  reward,

  /// Eltern-Nachricht
  parentMessage,

  /// System-Nachricht
  system,
}

/// Benachrichtigungs-Daten
class KidsNotification {
  const KidsNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type = NotificationType.system,
    this.imageUrl,
    this.data,
    this.scheduledTime,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final DateTime? scheduledTime;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'imageUrl': imageUrl,
        'data': data,
      };

  factory KidsNotification.fromMap(Map<String, dynamic> map) {
    return KidsNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => NotificationType.system,
      ),
      imageUrl: map['imageUrl'],
      data: map['data'],
    );
  }

  factory KidsNotification.fromRemoteMessage(RemoteMessage message) {
    return KidsNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == message.data['type'],
        orElse: () => NotificationType.system,
      ),
      imageUrl: message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      data: message.data,
    );
  }
}

/// Push Notification Service
class PushNotificationService {
  PushNotificationService._();

  static PushNotificationService? _instance;

  static PushNotificationService get instance {
    _instance ??= PushNotificationService._();
    return _instance!;
  }

  // Services
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // State
  bool _isInitialized = false;
  String? _fcmToken;

  // Callbacks
  void Function(KidsNotification)? onNotificationReceived;
  void Function(KidsNotification)? onNotificationTapped;
  void Function(String)? onTokenRefresh;

  // Getters
  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  /// Initialisiert den Service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Firebase Core initialisieren (falls noch nicht geschehen)
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Timezone initialisieren (für geplante Benachrichtigungen)
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Berlin'));

      // Berechtigungen anfordern
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        return false;
      }

      // Lokale Benachrichtigungen initialisieren
      await _initializeLocalNotifications();

      // FCM Token abrufen
      _fcmToken = await _messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $_fcmToken');
      }

      // Token-Refresh Handler
      _messaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        onTokenRefresh?.call(token);
      });

      // Foreground Messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Background Message Handler (muss top-level sein)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Notification Tap Handler
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check for initial message (App war geschlossen)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Push Notification init error: $e');
      }
      return false;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );

    // Android Notification Channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'kids_ai_channel',
              'Kids AI Benachrichtigungen',
              description: 'Benachrichtigungen für Kids AI Apps',
              importance: Importance.high,
            ),
          );
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = KidsNotification.fromRemoteMessage(message);
    onNotificationReceived?.call(notification);

    // Lokale Benachrichtigung anzeigen
    _showLocalNotification(notification);
  }

  void _handleNotificationTap(RemoteMessage message) {
    final notification = KidsNotification.fromRemoteMessage(message);
    onNotificationTapped?.call(notification);
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      // Payload parsen und Callback aufrufen
      onNotificationTapped?.call(KidsNotification(
        id: response.id?.toString() ?? '',
        title: '',
        body: '',
        data: {'payload': response.payload},
      ));
    }
  }

  /// Zeigt eine lokale Benachrichtigung an
  Future<void> _showLocalNotification(KidsNotification notification) async {
    final androidDetails = AndroidNotificationDetails(
      'kids_ai_channel',
      'Kids AI Benachrichtigungen',
      channelDescription: 'Benachrichtigungen für Kids AI Apps',
      importance: Importance.high,
      priority: Priority.high,
      icon: _getNotificationIcon(notification.type),
      color: _getNotificationColor(notification.type),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: notification.id,
    );
  }

  String _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return '@drawable/ic_reminder';
      case NotificationType.newContent:
        return '@drawable/ic_new';
      case NotificationType.reward:
        return '@drawable/ic_reward';
      case NotificationType.parentMessage:
        return '@drawable/ic_parent';
      case NotificationType.system:
        return '@mipmap/ic_launcher';
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return const Color(0xFF6C5CE7); // Primary
      case NotificationType.newContent:
        return const Color(0xFF00CEC9); // Secondary
      case NotificationType.reward:
        return const Color(0xFFFFD700); // Gold
      case NotificationType.parentMessage:
        return const Color(0xFFFDAA4C); // Accent
      case NotificationType.system:
        return const Color(0xFF74B9FF); // Info
    }
  }

  /// Zeigt sofort eine lokale Benachrichtigung an
  Future<void> showNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.system,
    Map<String, dynamic>? data,
  }) async {
    final notification = KidsNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      data: data,
    );
    await _showLocalNotification(notification);
  }

  /// Plant eine Benachrichtigung
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    NotificationType type = NotificationType.reminder,
    Map<String, dynamic>? data,
  }) async {
    final notification = KidsNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      data: data,
      scheduledTime: scheduledTime,
    );

    final androidDetails = AndroidNotificationDetails(
      'kids_ai_channel',
      'Kids AI Benachrichtigungen',
      channelDescription: 'Benachrichtigungen für Kids AI Apps',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      notification.id.hashCode,
      notification.title,
      notification.body,
      _convertToTZDateTime(scheduledTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: notification.id,
    );
  }

  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  /// Abonniert ein Topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Meldet sich von einem Topic ab
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Löscht alle Benachrichtigungen
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Löscht eine bestimmte Benachrichtigung
  Future<void> clearNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Setzt Badge-Zähler zurück (iOS)
  Future<void> resetBadge() async {
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        badge: false,
      );
    }
  }
}

/// Background Message Handler (muss top-level sein)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Hier können Background-Nachrichten verarbeitet werden
  if (kDebugMode) {
    print('Background message: ${message.messageId}');
  }
}

/// Erinnerungs-Presets für Kinder
class KidsReminders {
  KidsReminders._();

  /// Tägliche Lern-Erinnerung
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String? customMessage,
  }) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await PushNotificationService.instance.scheduleNotification(
      title: 'Zeit zum Lernen! 📚',
      body: customMessage ?? 'Lianko wartet auf dich! Lass uns spielen!',
      scheduledTime: scheduledTime,
      type: NotificationType.reminder,
    );
  }

  /// Belohnungs-Benachrichtigung
  static Future<void> showRewardNotification({
    required String rewardName,
    String? message,
  }) async {
    await PushNotificationService.instance.showNotification(
      title: 'Neue Belohnung! 🎉',
      body: message ?? 'Du hast $rewardName freigeschaltet!',
      type: NotificationType.reward,
    );
  }

  /// Neuer Inhalt verfügbar
  static Future<void> showNewContentNotification({
    required String contentName,
  }) async {
    await PushNotificationService.instance.showNotification(
      title: 'Neu für dich! ✨',
      body: '$contentName ist jetzt verfügbar!',
      type: NotificationType.newContent,
    );
  }
}
