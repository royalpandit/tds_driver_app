import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../data/services/storage_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final StorageService _storageService = StorageService();
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
        debugPrint('✅ User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('⚠️ User granted provisional notification permission');
      } else {
        debugPrint('❌ User declined notification permission');
      }

      // Get FCM token
      await _getFCMToken();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔄 FCM Token refreshed: $newToken');
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
        debugPrint('📬 App opened from terminated state via notification');
        _handleMessageOpenedApp(initialMessage);
      }

    } catch (e) {
      debugPrint('❌ Error initializing Firebase: $e');
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
        debugPrint('🔑 FCM Token: $_fcmToken');
        await _saveFCMToken(_fcmToken!);
      }
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
    }
  }

  Future<void> _saveFCMToken(String token) async {
    await _storageService.saveFirebaseToken(token);
  }

  String? getFCMToken() {
    return _fcmToken;
  }

  Future<String?> getSavedFCMToken() async {
    return _storageService.getFirebaseToken();
  }

  Future<void> saveFirebaseToken(String token) async {
    await _saveFCMToken(token);
  }

  Future<String?> getSavedFirebaseToken() async {
    return getSavedFCMToken();
  }

  Future<void> refreshFCMToken() async {
    await _getFCMToken();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📨 Foreground message received!');
    debugPrint('📋 Title: ${message.notification?.title}');
    debugPrint('📋 Body: ${message.notification?.body}');
    debugPrint('📦 Data: ${message.data}');

    // Show local notification when in foreground
    _showLocalNotification(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    // Build title/body preferring notification payload, then data fields
    final title = notification?.title ?? data['title'] ?? data['message_title'] ?? data['title_text'] ?? '';
    final body = notification?.body ?? data['body'] ?? data['message'] ?? data['body_text'] ?? '';

    // Determine image URL if provided
    final imageUrl = data['image'] ?? data['image_url'] ?? notification?.android?.imageUrl ?? notification?.apple?.imageUrl;

    AndroidNotificationDetails androidDetails;
    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      try {
        final bigPicturePath = await _downloadAndSaveFile(imageUrl.toString(), 'bigpicture_${message.messageId ?? DateTime.now().millisecondsSinceEpoch}');
        final bigPicture = FilePathAndroidBitmap(bigPicturePath);
        androidDetails = AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/notification_icon',
          styleInformation: BigPictureStyleInformation(bigPicture, hideExpandedLargeIcon: false),
        );
      } catch (e) {
        debugPrint('❌ Failed to download notification image: $e');
        androidDetails = const AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/notification_icon',
        );
      }
    } else {
      androidDetails = const AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@drawable/notification_icon',
      );
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      title.isNotEmpty ? title : null,
      body.isNotEmpty ? body : null,
      notificationDetails,
      payload: '${data['type'] ?? ''}|${data['ride_request_id'] ?? data['trip_id'] ?? ''}|${data['image'] ?? ''}',
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }

  void _handleNotificationTap(String payload) {
    debugPrint('🔔 Notification tapped with payload: $payload');
    
    final parts = payload.split('|');
    if (parts.isEmpty) return;

    final type = parts[0];
    final id = parts.length > 1 ? parts[1] : null;

    _navigateBasedOnType(type, id);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('🔔 Notification opened app!');
    debugPrint('📦 Data: ${message.data}');
    
    final data = message.data;
    final type = data['type'] ?? '';
    final id = data['ride_request_id'] ?? data['trip_id'] ?? '';
    
    _navigateBasedOnType(type, id);
  }

  void _navigateBasedOnType(String type, String? id) {
    if (_navigatorKey?.currentContext == null) {
      debugPrint('⚠️ Navigator context not available');
      return;
    }

    final context = _navigatorKey!.currentContext!;

    switch (type) {
      case 'new_ride_request':
      case 'ride_request':
        debugPrint('🚗 Navigating to Ride Request screen');
        _navigateToRideRequests(context);
        break;
        
      case 'trip_start':
      case 'trip_started':
        debugPrint('🏁 Navigating to Trip Details (Start)');
        if (id != null && id.isNotEmpty) {
          _navigateToTripDetails(context, int.tryParse(id));
        } else {
          _navigateToTrips(context);
        }
        break;
        
      case 'trip_end':
      case 'trip_completed':
        debugPrint('🏁 Navigating to Trip Details (End)');
        if (id != null && id.isNotEmpty) {
          _navigateToTripDetails(context, int.tryParse(id));
        } else {
          _navigateToTrips(context);
        }
        break;
        
      case 'trip_update':
      case 'trip_notification':
        debugPrint('📍 Navigating to Trip Details (Update)');
        if (id != null && id.isNotEmpty) {
          _navigateToTripDetails(context, int.tryParse(id));
        } else {
          _navigateToTrips(context);
        }
        break;
        
      case 'today_trips':
      case 'daily_trips':
        debugPrint('📅 Navigating to Today\'s Trips');
        _navigateToTrips(context);
        break;
        
      case 'payment':
        debugPrint('💰 Navigating to Payments/Earnings');
        _navigateToHome(context);
        break;
        
      default:
        debugPrint('🏠 Navigating to Home (default)');
        _navigateToHome(context);
        break;
    }
  }

  void _navigateToHome(BuildContext context) {
    try {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
    }
  }

  void _navigateToRideRequests(BuildContext context) {
    try {
      // Import dynamically to avoid circular dependencies
      Navigator.of(context).pushNamed('/ride-requests');
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
      _navigateToHome(context);
    }
  }

  void _navigateToTrips(BuildContext context) {
    try {
      Navigator.of(context).pushNamed('/trips');
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
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
      debugPrint('❌ Navigation error: $e');
      _navigateToTrips(context);
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('❌ Firebase.initializeApp() failed in background handler: $e');
      return;
    }
  }

  debugPrint("📨 Background message received: ${message.messageId}");
  debugPrint('📋 Title: ${message.notification?.title}');
  debugPrint('📋 Body: ${message.notification?.body}');
  debugPrint('📦 Data: ${message.data}');
  
  // Show local notification for background messages (support data-only and images)
  try {
    final data = message.data;
    final title = message.notification?.title ?? data['title'] ?? data['message_title'] ?? '';
    final body = message.notification?.body ?? data['body'] ?? data['message'] ?? '';
    final imageUrl = data['image'] ?? data['image_url'] ?? message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl;

    final localNotifications = FlutterLocalNotificationsPlugin();

    AndroidNotificationDetails androidDetails;
    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl.toString()));
        final bytes = response.bodyBytes;
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/bg_bigpicture_${message.messageId ?? DateTime.now().millisecondsSinceEpoch}';
        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);

        final bigPicture = FilePathAndroidBitmap(filePath);
        androidDetails = AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/notification_icon',
          styleInformation: BigPictureStyleInformation(bigPicture, hideExpandedLargeIcon: false),
        );
      } catch (e) {
        debugPrint('❌ Background image download failed: $e');
        androidDetails = const AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/notification_icon',
        );
      }
    } else {
      androidDetails = const AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@drawable/notification_icon',
      );
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await localNotifications.show(
      message.hashCode,
      title.isNotEmpty ? title : null,
      body.isNotEmpty ? body : null,
      notificationDetails,
      payload: '${data['type'] ?? ''}|${data['ride_request_id'] ?? data['trip_id'] ?? ''}|${data['image'] ?? ''}',
    );
  } catch (e) {
    debugPrint('❌ Error showing background local notification: $e');
  }
}