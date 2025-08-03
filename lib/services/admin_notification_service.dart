import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize FCM for admin app
  static Future<void> initializeAdminNotifications() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ Admin not authenticated');
        return;
      }

      // Request notification permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print('❌ Notification permissions not granted');
        return;
      }

      // Get FCM token
      final token = await _messaging.getToken();
      if (token == null) {
        print('❌ Failed to get FCM token');
        return;
      }

      print('📱 Admin FCM Token: $token');

      // Store token in admin document
      await _firestore.collection('admin').doc(currentUser.uid).update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      print('✅ Admin FCM token stored successfully');

      // Handle token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        print('🔄 Admin token refreshed: $newToken');
        await _firestore.collection('admin').doc(currentUser.uid).update({
          'fcmToken': newToken,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      });

    } catch (e) {
      print('❌ Error initializing admin notifications: $e');
    }
  }

  // Setup foreground message handler for admin app
  static void setupAdminMessageHandler() {
    print('=================');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📧 Admin received foreground message: ${message.notification?.title}');

      // Show in-app notification or update admin dashboard
      _handleAdminNotification(message);
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📧 Admin tapped notification: ${message.data}');
      _handleNotificationTap(message);
    });
  }

  static void _handleAdminNotification(RemoteMessage message) {
    final data = message.data;

    if (data['type'] == 'new_order') {
      // Update admin dashboard, show badge, etc.
      print('🔔 New order notification: Order ${data['orderId']}');

      // You can emit a notification event to your BLoC here
      // Example: AdminDashboardBloc.instance.add(NewOrderReceived(data['orderId']));
    }
  }

  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;

    if (data['type'] == 'new_order') {
      final orderId = data['orderId'];
      // Navigate to order details screen
      // NavigationService.navigateToOrderDetails(orderId);
    }
  }
}
