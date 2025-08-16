import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:raising_india/models/product_model.dart';

class LowStockNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ✅ Initialize low stock monitoring
  static void initializeLowStockMonitoring() {
    _firestore
        .collection('low_stock_alerts')
        .where('isResolved', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _handleNewLowStockAlert(change.doc);
        }
      }
    });
  }

  // ✅ Handle new low stock alert
  static Future<void> _handleNewLowStockAlert(DocumentSnapshot alertDoc) async {
    try {
      final alertData = alertDoc.data() as Map<String, dynamic>;
      final productId = alertData['productId'];
      final currentStock = alertData['currentStock'].toDouble();
      final severity = alertData['severity'];

      // Get product details
      final productDoc = await _firestore.collection('products').doc(productId).get();
      if (!productDoc.exists) return;

      final product = ProductModel.fromMap(productDoc.data()!, productDoc.id);

      // ✅ Send notification to admin
      await _sendLowStockNotification(product, currentStock, severity);

      // ✅ Log notification
      await _logNotification(product, currentStock, severity);

    } catch (e) {
      print('❌ Error handling low stock alert: $e');
    }
  }

  // ✅ Send push notification to admin
  static Future<void> _sendLowStockNotification(ProductModel product, double currentStock, String severity) async {
    try {
      final title = severity == 'CRITICAL' ? '🚨 Out of Stock Alert!' : '⚠️ Low Stock Alert';
      final body = severity == 'CRITICAL'
          ? '${product.name} is now out of stock!'
          : '${product.name} is running low (${currentStock.toInt()} left)';

      // ✅ Send to admin topic (all admin devices)
      await _messaging.sendMessage(
        to: '/topics/admin_alerts',
        data: {
          'type': 'low_stock',
          'productId': product.pid,
          'productName': product.name,
          'currentStock': currentStock.toString(),
          'severity': severity,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },

        /*notification: RemoteNotification(
          title: title,
          body: body,
          android: AndroidNotification(
            channelId: 'low_stock_alerts',
            priority: AndroidNotificationPriority.highPriority,
            color: severity == 'CRITICAL' ? '#FF0000' : '#FFA500',
          ),
          apple: AppleNotification(
            sound: AppleNotificationSound(critical: true),
            badge: '1',
          ),
        ),*/
      );
    } catch (e) {
      print('❌ Error sending low stock notification: $e');
    }
  }

  // ✅ Log notification for tracking
  static Future<void> _logNotification(ProductModel product, double currentStock, String severity) async {
    try {
      await _firestore.collection('admin_notifications').add({
        'type': 'LOW_STOCK',
        'title': severity == 'CRITICAL' ? 'Out of Stock Alert' : 'Low Stock Alert',
        'message': severity == 'CRITICAL'
            ? '${product.name} is now out of stock!'
            : '${product.name} is running low (${currentStock.toInt()} units left)',
        'productId': product.pid,
        'productName': product.name,
        'currentStock': currentStock,
        'lowStockThreshold': product.lowStockQuantity,
        'severity': severity,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(days: 7)), // Auto-expire in 7 days
      });
    } catch (e) {
      print('❌ Error logging notification: $e');
    }
  }

  // ✅ Check all products for low stock (manual trigger)
  static Future<void> checkAllProductsForLowStock() async {
    try {
      final productsSnapshot = await _firestore.collection('products').get();

      for (var doc in productsSnapshot.docs) {
        final product = ProductModel.fromMap(doc.data(), doc.id);

        if (product.isLowStock) {
          // Check if alert already exists
          final existingAlert = await _firestore
              .collection('low_stock_alerts')
              .doc(product.pid)
              .get();

          if (!existingAlert.exists) {
            // Create new alert
            await _firestore.collection('low_stock_alerts').doc(product.pid).set({
              'productId': product.pid,
              'currentStock': product.stockQuantity,
              'threshold': product.lowStockQuantity,
              'alertCreatedAt': FieldValue.serverTimestamp(),
              'isResolved': false,
              'severity': product.stockQuantity! <= 0 ? 'CRITICAL' : 'WARNING',
            });
          }
        }
      }
    } catch (e) {
      print('❌ Error checking products for low stock: $e');
    }
  }
}
