import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'api_service.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();

  // Cache today's meal
  dynamic _todaysMeal;
  bool _hasShownNotification = false;

  // Initialize notifications
  Future<void> initialize() async {
    if (kIsWeb) {
      // Web platform - simplified initialization
      if (kDebugMode) {
        print('🌐 Initializing web notifications...');
      }

      // Show a test notification immediately on web
      await scheduleDailyNotification();
      return;
    }

    // Mobile platform - full Firebase Messaging setup
    // Request permission for iOS/Android
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }

    // Get FCM token
    String? token = await _messaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'recipe_daily_channel',
      'Daily Recipe Notifications',
      description: 'Daily random recipe notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Schedule daily notification
    await scheduleDailyNotification();
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message received: ${message.notification?.title}');
    }

    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? 'New Recipe',
        body: message.notification!.body ?? 'Check out today\'s recipe!',
      );
    }
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    // You can add navigation logic here
  }

  // Handle message when app opened from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('Message opened app: ${message.notification?.title}');
    }
    // You can add navigation logic here
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'recipe_daily_channel',
      'Daily Recipe Notifications',
      channelDescription: 'Daily random recipe notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      Random().nextInt(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Schedule daily notification at 10:00 AM
  Future<void> scheduleDailyNotification() async {
    // Get a random meal
    try {
      final meal = await _apiService.getRandomMeal();

      if (kIsWeb) {
        // Web platform - use browser notifications
        _showWebNotification(
          title: 'Рецепт на денот! 🍽️',
          body: 'Погледнете го денешниот рецепт: ${meal.strMeal}',
        );
      } else {
        // Mobile platform - use local notifications
        await _showLocalNotification(
          title: 'Рецепт на денот! 🍽️',
          body: 'Погледнете го денешниот рецепт: ${meal.strMeal}',
          payload: meal.idMeal,
        );
      }

      if (kDebugMode) {
        print('Daily notification scheduled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling notification: $e');
      }
    }
  }

  // Show web notification using browser API
  void _showWebNotification({required String title, required String body}) {
    if (kIsWeb) {
      // For web, we'll show an in-app notification instead
      // This will be handled by the UI layer
      if (kDebugMode) {
        print('✅ Web notification prepared: $title - $body');
      }
    }
  }

  // Get today's random meal (cached for the session)
  Future<dynamic> getTodaysMeal() async {
    if (_todaysMeal != null) {
      return _todaysMeal;
    }
    try {
      _todaysMeal = await _apiService.getRandomMeal();
      return _todaysMeal;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting today\'s meal: $e');
      }
      rethrow;
    }
  }

  // Check if notification has been shown
  bool get hasShownNotification => _hasShownNotification;

  // Mark notification as shown
  void markNotificationAsShown() {
    _hasShownNotification = true;
  }

  // Send test notification
  Future<void> sendTestNotification() async {
    try {
      final meal = await _apiService.getRandomMeal();
      await _showLocalNotification(
        title: 'Рецепт на денот! 🍽️',
        body: 'Погледнете го денешниот рецепт: ${meal.strMeal}',
        payload: meal.idMeal,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending test notification: $e');
      }
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message received: ${message.notification?.title}');
  }
}
