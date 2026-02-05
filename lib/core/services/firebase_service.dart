import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  String? _fcmToken;
  GlobalKey<NavigatorState>? _navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> initializeFirebase() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permission for iOS
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ User granted provisional notification permission');
      } else {
        print('❌ User declined notification permission');
      }

      // Get FCM token
      await _getFCMToken();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('🔄 FCM Token refreshed: $newToken');
        _saveFCMToken(newToken);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle initial message when app is launched from terminated state
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print('📬 App opened from terminated state via notification');
        _handleMessageOpenedApp(initialMessage);
      }

    } catch (e) {
      print('❌ Error initializing Firebase: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@drawable/notification_icon');
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
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _handleNotificationTap(response.payload!);
        }
      },
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        print('🔑 FCM Token: $_fcmToken');
        await _saveFCMToken(_fcmToken!);
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  Future<void> _saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  String? getFCMToken() {
    return _fcmToken;
  }

  Future<String?> getSavedFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  Future<void> refreshFCMToken() async {
    await _getFCMToken();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Foreground message received!');
    print('📋 Title: ${message.notification?.title}');
    print('📋 Body: ${message.notification?.body}');
    print('📦 Data: ${message.data}');

    // Show local notification when in foreground
    _showLocalNotification(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;
    
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@drawable/notification_icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: '${data['type']}|${data['ride_request_id'] ?? data['trip_id'] ?? ''}',
    );
  }

  void _handleNotificationTap(String payload) {
    print('🔔 Notification tapped with payload: $payload');
    
    final parts = payload.split('|');
    if (parts.isEmpty) return;

    final type = parts[0];
    final id = parts.length > 1 ? parts[1] : null;

    _navigateBasedOnType(type, id);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('🔔 Notification opened app!');
    print('📦 Data: ${message.data}');
    
    final data = message.data;
    final type = data['type'] ?? '';
    final id = data['ride_request_id'] ?? data['trip_id'] ?? '';
    
    _navigateBasedOnType(type, id);
  }

  void _navigateBasedOnType(String type, String? id) {
    if (_navigatorKey?.currentContext == null) {
      print('⚠️ Navigator context not available');
      return;
    }

    final context = _navigatorKey!.currentContext!;

    switch (type) {
      case 'new_ride_request':
      case 'ride_request':
        print('🚗 Navigating to Ride Request screen');
        _navigateToRideRequests(context);
        break;
        
      case 'trip_start':
      case 'trip_started':
        print('🏁 Navigating to Trip Details (Start)');
        if (id != null && id.isNotEmpty) {
          _navigateToTripDetails(context, int.tryParse(id));
        } else {
          _navigateToTrips(context);
        }
        break;
        
      case 'trip_end':
      case 'trip_completed':
        print('🏁 Navigating to Trip Details (End)');
        if (id != null && id.isNotEmpty) {
          _navigateToTripDetails(context, int.tryParse(id));
        } else {
          _navigateToTrips(context);
        }
        break;
        
      case 'trip_update':
      case 'trip_notification':
        print('📍 Navigating to Trip Details (Update)');
        if (id != null && id.isNotEmpty) {
          _navigateToTripDetails(context, int.tryParse(id));
        } else {
          _navigateToTrips(context);
        }
        break;
        
      case 'today_trips':
      case 'daily_trips':
        print('📅 Navigating to Today\'s Trips');
        _navigateToTrips(context);
        break;
        
      case 'payment':
        print('💰 Navigating to Payments/Earnings');
        _navigateToHome(context);
        break;
        
      default:
        print('🏠 Navigating to Home (default)');
        _navigateToHome(context);
        break;
    }
  }

  void _navigateToHome(BuildContext context) {
    try {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      print('❌ Navigation error: $e');
    }
  }

  void _navigateToRideRequests(BuildContext context) {
    try {
      // Import dynamically to avoid circular dependencies
      Navigator.of(context).pushNamed('/ride-requests');
    } catch (e) {
      print('❌ Navigation error: $e');
      _navigateToHome(context);
    }
  }

  void _navigateToTrips(BuildContext context) {
    try {
      Navigator.of(context).pushNamed('/trips');
    } catch (e) {
      print('❌ Navigation error: $e');
      _navigateToHome(context);
    }
  }

  void _navigateToTripDetails(BuildContext context, int? tripId) {
    if (tripId == null) {
      _navigateToTrips(context);
      return;
    }
    
    try {
      Navigator.of(context).pushNamed('/trip-details', arguments: tripId);
    } catch (e) {
      print('❌ Navigation error: $e');
      _navigateToTrips(context);
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('❌ Firebase.initializeApp() failed in background handler: $e');
      return;
    }
  }
  
  print("📨 Background message received: ${message.messageId}");
  print('📋 Title: ${message.notification?.title}');
  print('📋 Body: ${message.notification?.body}');
  print('📦 Data: ${message.data}');
  
  // Show local notification for background messages
  final notification = message.notification;
  if (notification != null) {
    final localNotifications = FlutterLocalNotificationsPlugin();
    
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@drawable/notification_icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final data = message.data;
    await localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: '${data['type']}|${data['ride_request_id'] ?? data['trip_id'] ?? ''}',
    );
  }
}