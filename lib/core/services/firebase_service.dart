import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  GlobalKey<NavigatorState>? _navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> initializeFirebase() async {
    try {
      // Initialize Firebase with timeout
      await Firebase.initializeApp().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Firebase initialization timed out');
          throw Exception('Firebase initialization timeout');
        },
      );

      // Request permission for iOS
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }

      // Get FCM token
      await _getFCMToken();

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle initial message when app is launched from terminated state
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

    } catch (e) {
      print('Error initializing Firebase: $e');
      // Continue without Firebase if it fails
    }
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        print('FCM Token: $_fcmToken');
        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
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
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      _showNotificationDialog(message);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message clicked!');
    // Handle navigation based on message data
    _handleNotificationNavigation(message);
  }

  void _showNotificationDialog(RemoteMessage message) {
    if (_navigatorKey?.currentContext == null) return;

    final context = _navigatorKey!.currentContext!;
    final notification = message.notification;

    if (notification == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification.title ?? 'Notification'),
          content: Text(notification.body ?? ''),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleNotificationNavigation(message);
              },
              child: const Text('View'),
            ),
          ],
        );
      },
    );
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    if (_navigatorKey?.currentContext == null) return;

    // Handle navigation based on notification type
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'ride_request':
        // Navigate to ride request screen
        // You can implement navigation logic here
        break;
      case 'trip_update':
        // Navigate to trip details
        break;
      case 'payment':
        // Navigate to payment screen
        break;
      default:
        // Navigate to home
        break;
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification}');
}