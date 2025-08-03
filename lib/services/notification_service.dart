import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raising_india/features/admin/order/screens/admin_order_details_screen.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize FCM for users
  static Future<void> initializeUserNotifications() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await _messaging.getToken();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (token != null && userId != null) {
      await _firestore.collection('userTokens').doc(userId).set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // Handle token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      if (userId != null) {
        await _firestore.collection('userTokens').doc(userId).update({
          'token': newToken,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Initialize FCM for admins
  static Future<void> initializeAdminNotifications() async {
    await _messaging.requestPermission();
    final token = await _messaging.getToken();

    if (token != null) {
      await _firestore.collection('adminTokens').doc(token).set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Handle foreground messages
  static void setupForegroundMessageHandler() {
    print('=========================');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Show in-app notification or update UI
      print('-----------------Foreground message: ${message.notification?.title}');
    });
  }

  // Handle notification taps
  static void setupNotificationClickHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });
  }

  static void _handleNotificationClick(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];

    if (type == 'new_order' || type == 'order_update') {
      final orderId = data['orderId'];
      AdminOrderDetailsScreen(orderId: orderId);
    }
  }
}
