import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raising_india/models/product_model.dart';
import 'package:raising_india/models/order_model.dart';

class StockManagementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Deduct stock when order is placed/confirmed
  Future<bool> deductStock(String productId, double quantityOrdered) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final productRef = _firestore.collection('products').doc(productId);
        final productDoc = await transaction.get(productRef);

        if (!productDoc.exists) {
          throw Exception('Product not found');
        }

        final currentStock = (productDoc.data()!['stockQuantity'] ?? 0).toDouble();

        /*// ✅ Check if enough stock available
        if (currentStock < quantityOrdered) {
          throw Exception('Insufficient stock. Available: $currentStock, Requested: $quantityOrdered');
        }*/

        final newStock = currentStock - quantityOrdered;

        // ✅ Update stock quantity
        transaction.update(productRef, {
          'stockQuantity': newStock,
          'lastStockUpdate': FieldValue.serverTimestamp(),
          'isAvailable': newStock > 0, // Auto-disable if out of stock
        });

        // ✅ Check if stock is now low and create alert
        final lowStockThreshold = (productDoc.data()!['lowStockQuantity'] ?? 10).toDouble();
        if (newStock <= lowStockThreshold) {
          await _createLowStockAlert(transaction, productId, newStock, lowStockThreshold);
        }

        return true;
      });
    } catch (e) {
      print('❌ Error deducting stock: $e');
      return false;
    }
  }

  // refill stock.
  Future<bool> refillStock(String productId, double quantityToFill, double lowStockThreshold) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final productRef = _firestore.collection('products').doc(productId);
        // ✅ Update stock quantity
        transaction.update(productRef, {
          'stockQuantity': quantityToFill,
          'lastStockUpdate': FieldValue.serverTimestamp(),
        });

        if (quantityToFill > lowStockThreshold) {
          await _removeLowStockAlert(transaction, productId);
        }
        return true;
      });
    } catch (e) {
      print('❌ Error restoring stock: $e');
      return false;
    }
  }

  // ✅ Restore stock when order is cancelled
  Future<bool> restoreStock(String productId, double quantityToRestore) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final productRef = _firestore.collection('products').doc(productId);
        final productDoc = await transaction.get(productRef);

        if (!productDoc.exists) {
          throw Exception('Product not found');
        }

        final currentStock = (productDoc.data()!['stockQuantity'] ?? 0).toDouble();
        final newStock = currentStock + quantityToRestore;

        // ✅ Update stock quantity
        transaction.update(productRef, {
          'stockQuantity': newStock,
          'lastStockUpdate': FieldValue.serverTimestamp(),
          'isAvailable': true, // Re-enable product
        });

        // ✅ Remove low stock alert if stock is now sufficient
        final lowStockThreshold = (productDoc.data()!['lowStockQuantity'] ?? 10).toDouble();
        if (newStock > lowStockThreshold) {
          await _removeLowStockAlert(transaction, productId);
        }

        return true;
      });
    } catch (e) {
      print('❌ Error restoring stock: $e');
      return false;
    }
  }

  // ✅ Deduct stock for entire order
  Future<bool> processOrderStockDeduction(OrderModel order) async {
    try {
      // Group items by product to handle multiple quantities of same product
      Map<String, double> productQuantities = {};

      for (var item in order.items) {
        final productId = item['productId'];
        final quantity = double.parse(item['quantity'].toString());

        if (productQuantities.containsKey(productId)) {
          productQuantities[productId] = productQuantities[productId]! + quantity;
        } else {
          productQuantities[productId] = quantity;
        }
      }

      // ✅ Process each product's stock deduction
      for (var entry in productQuantities.entries) {
        final success = await deductStock(entry.key, entry.value);
        if (!success) {
          // ✅ If any product fails, restore previously deducted stock
          await _rollbackStockDeduction(order.orderId, productQuantities);
          return false;
        }
      }

      return true;
    } catch (e) {
      print('❌ Error processing order stock deduction: $e');
      return false;
    }
  }

  // ✅ Restore stock for cancelled order
  Future<bool> processOrderStockRestoration(OrderModel order) async {
    try {
      // Group items by product
      Map<String, double> productQuantities = {};

      for (var item in order.items) {
        final productId = item['productId'];
        final quantity = double.parse(item['quantity'].toString());

        if (productQuantities.containsKey(productId)) {
          productQuantities[productId] = productQuantities[productId]! + quantity;
        } else {
          productQuantities[productId] = quantity;
        }
      }

      // ✅ Restore each product's stock
      for (var entry in productQuantities.entries) {
        await restoreStock(entry.key, entry.value);
      }
      return true;
    } catch (e) {
      print('❌ Error processing order stock restoration: $e');
      return false;
    }
  }

  // ✅ Get all low stock products
  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .get();

      List<ProductModel> lowStockProducts = [];

      for (var doc in querySnapshot.docs) {
        final product = ProductModel.fromMap(doc.data(), doc.id);
        if (product.isLowStock) {
          lowStockProducts.add(product);
        }
      }
      // Sort by urgency (lowest stock first)
      lowStockProducts.sort((a, b) => a.stockQuantity!.compareTo(b.stockQuantity!));
      return lowStockProducts;
    } catch (e) {
      print('❌ Error getting low stock products: $e');
      return [];
    }
  }

  // ✅ Create low stock alert
  Future<void> _createLowStockAlert(Transaction transaction, String productId, double currentStock, double threshold) async {
    final alertRef = _firestore.collection('low_stock_alerts').doc(productId);

    transaction.set(alertRef, {
      'productId': productId,
      'currentStock': currentStock,
      'threshold': threshold,
      'alertCreatedAt': FieldValue.serverTimestamp(),
      'isResolved': false,
      'severity': currentStock <= 0 ? 'CRITICAL' : 'WARNING',
    });
  }

  // ✅ Remove low stock alert
  Future<void> _removeLowStockAlert(Transaction transaction, String productId) async {
    final alertRef = _firestore.collection('low_stock_alerts').doc(productId);
    transaction.delete(alertRef);
  }

  // ✅ Rollback stock deduction if order processing fails
  Future<void> _rollbackStockDeduction(String orderId, Map<String, double> productQuantities) async {
    print('🔄 Rolling back stock deduction for order: $orderId');

    for (var entry in productQuantities.entries) {
      await restoreStock(entry.key, entry.value);
    }
  }
}
