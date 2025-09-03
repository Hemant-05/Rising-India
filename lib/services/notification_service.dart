import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/features/admin/order/screens/admin_order_details_screen.dart';
import 'package:raising_india/features/admin/stock_management/screens/low_stock_alert_screen.dart';
import 'package:raising_india/features/services/order_services.dart';
import 'package:raising_india/features/user/order/screens/order_details_screen.dart';
import 'package:raising_india/features/user/order/screens/order_tracking_screen.dart';
import 'package:raising_india/models/order_with_product_model.dart';

import '../main.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Prevent duplicate notifications
  static final Set<String> _shownNotifications = <String>{};

  /// Initialize the notification service
  static Future<void> initialize() async {
    // Request permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _initializeLocalNotifications();
      await _saveTokenToFirestore();
      _setupMessageHandlers();

    } else {
      print('❌ Notification permission denied');
    }
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
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
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  /// Create notification channels
  static Future<void> _createNotificationChannels() async {
    const orderChannel = AndroidNotificationChannel(
      'order_notifications',
      'Order Updates',
      description: 'Notifications for order status updates',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

/*    const paymentChannel = AndroidNotificationChannel(
      'payment_notifications',
      'Payment Updates',
      description: 'Notifications for payment status updates',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );*/

    const adminChannel = AndroidNotificationChannel(
      'admin_notifications',
      'Admin Alerts',
      description: 'Administrative notifications and alerts',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(orderChannel);
      // await androidPlugin.createNotificationChannel(paymentChannel);
      await androidPlugin.createNotificationChannel(adminChannel);
    }
  }

  /// Save FCM token to Firestore
  static Future<void> _saveTokenToFirestore() async {
    try {
      final token = await _messaging.getToken();
      final user = FirebaseAuth.instance.currentUser;

      if (token != null && user != null) {

        final isAdmin = await _checkIfUserIsAdmin(user.uid);
        if(isAdmin){
          await _firestore.collection('admin').doc(user.uid).update({
            'fcmToken': token,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
            'platform': defaultTargetPlatform.name,
          });
        }else{
          await _firestore.collection('users').doc(user.uid).update({
            'fcmToken': token,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
            'platform': defaultTargetPlatform.name,
          });
        }

        // Save to tokens collection for admin access
        await _firestore.collection('userTokens').doc(user.uid).set({
          'token': token,
          'userId': user.uid,
          'email': user.email,
          'isAdmin': isAdmin,
          'platform': defaultTargetPlatform.name,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('✅ FCM token saved successfully');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  /// Check if user is admin
  static Future<bool> _checkIfUserIsAdmin(String uid) async {
    try {
      final adminDoc = await _firestore.collection('admin').doc(uid).get();
      return adminDoc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Setup message handlers
  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle initial message
    _handleInitialMessage();

    // Handle token refresh
    _messaging.onTokenRefresh.listen((_) => _saveTokenToFirestore());
  }

  /// Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📱 Foreground message: ${message.notification?.title}');

    // Create unique ID to prevent duplicates
    final notificationId = message.messageId ??
        message.data['orderId'] ??
        DateTime.now().millisecondsSinceEpoch.toString();

    if (_shownNotifications.contains(notificationId)) {
      print('⚠️ Duplicate notification prevented');
      return;
    }

    _shownNotifications.add(notificationId);
    _cleanupOldNotificationIds();

    // Show local notification
    await _showLocalNotification(message);
  }

  /// Clean up old notification IDs
  static void _cleanupOldNotificationIds() {
    if (_shownNotifications.length > 100) {
      final oldIds = _shownNotifications.take(50).toList();
      _shownNotifications.removeAll(oldIds);
    }
  }

  /// Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notificationType = message.data['type'] ?? 'order';

    // Choose channel based on notification type
    String channelId;
    Color notificationColor;

    if (notificationType.contains('payment') || notificationType.contains('refund')) {
      channelId = 'payment_notifications';
      notificationColor = Colors.green;
    } else if (message.data['isAdmin'] == 'true') {
      channelId = 'admin_notifications';
      notificationColor = Colors.orange;
    } else {
      channelId = 'order_notifications';
      notificationColor = const Color(0xFFFF6B35);
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: notificationColor,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? 'You have a new update',
      platformDetails,
      payload: message.data.toString(),
    );
  }

  /// Get channel name
  static String _getChannelName(String channelId) {
    switch (channelId) {
      case 'payment_notifications':
        return 'Payment Updates';
      case 'admin_notifications':
        return 'Admin Alerts';
      default:
        return 'Order Updates';
    }
  }

  /// Handle notification tap when app is already opened
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final Map<String, dynamic> data = _parsePayload(response.payload!);
        _handleNavigation(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  /// Handle notification tap from background
  static void _handleNotificationTap(RemoteMessage message) {
    print('📱 Notification tapped from background: ${message.data}');
    _handleNavigation(message.data);
  }

  /// Handle initial message
  static Future<void> _handleInitialMessage() async {
    print('📱 Handling initial message...');
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('📱 App opened from notification: ${initialMessage.data}');
      _handleNotificationTap(initialMessage);
    }
  }

  static Map<String, dynamic> _parsePayload(String payloadString) {
    try {
      if (payloadString.startsWith('{') && payloadString.endsWith('}')) {
        final Map<String, dynamic> data = {};
        final entries = payloadString
            .substring(1, payloadString.length - 1)
            .split(',')
            .map((e) => e.trim());
        for (var entry in entries) {
          final parts = entry.split(':').map((s) => s.trim()).toList();
          if (parts.length == 2) {
            data[parts[0]] = parts[1];
          }
        }
        return data;
      }
      return {};
    } catch (e) {
      print("Error in _parsePayload: $e");
      return {};
    }
  }

  /// Common handler for navigating based on notification data
  static Future<void> _handleNavigation(Map<String, dynamic> data) async {
    final String? screen = data['screen'] as String?;

    if (screen != null) {
      print('Navigating for type: $screen with data: $data');
      switch (screen) {
        case 'order_details':
          final orderId = data['orderId'];
          if (orderId != null) {
            if (navigatorKey.currentState != null) {
              navigatorKey.currentState!.push(MaterialPageRoute(
                builder: (context) => OrderTrackingScreen(orderId: orderId,),
              ));
            }
          }
          break;
        case 'low_stock_alerts':
          navigatorKey.currentState!.push(MaterialPageRoute(
            builder: (context) => LowStockAlertScreen(),
          ));
          break;
        /*case 'admin_order_details':
          final order = await OrderServices().getOrderById(data['orderId']);
          final orderWithProducts = OrderWithProducts(order: order, products: []);
          navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => AdminOrderDetailScreen(orderWithProducts: orderWithProducts),));
          break;*/
        default:
          print('Unknown notification type for navigation: $screen');
      }
    } else {
      print('Notification data does not contain a "type" for navigation.');
    }
  }



  /// Refresh FCM token
  static Future<void> refreshToken() async {
    try{
      await _saveTokenToFirestore();
      /*String dateString = DateFormat('d').format(DateTime.now());
      print(dateString);
      if(dateString == '3'){
        await _saveTokenToFirestore();
      }*/
    }catch(e){
      print('error : $e');
    }
  }

  /// Clear FCM token (on logout)
  static Future<void> clearToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if(await _checkIfUserIsAdmin(user.uid)){
          await _firestore.collection('admin').doc(user.uid).update({
            'fcmToken': FieldValue.delete(),
            'lastTokenUpdate': FieldValue.serverTimestamp(),
            'platform': defaultTargetPlatform.name,
          });
        }else{
          await _firestore.collection('users').doc(user.uid).update({
            'fcmToken': FieldValue.delete(),
            'lastTokenUpdate': FieldValue.serverTimestamp(),
            'platform': defaultTargetPlatform.name,
          });
        }
        await _firestore.collection('userTokens').doc(user.uid).delete();
        print('✅ FCM token cleared');
      }
      _shownNotifications.clear();
    } catch (e) {
      print('❌ Error clearing FCM token: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    _shownNotifications.clear();
  }
}
