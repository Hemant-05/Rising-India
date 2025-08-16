import 'package:raising_india/features/services/stock_management_repository.dart';
import 'package:raising_india/models/order_model.dart';

class OrderProcessingService {
  final StockManagementRepository _stockRepository = StockManagementRepository();

  // ✅ Process order confirmation with stock deduction
  Future<bool> confirmOrder(OrderModel order) async {
    try {
      // 1. Deduct stock first
      final stockDeducted = await _stockRepository.processOrderStockDeduction(order);

      if (!stockDeducted) {
        throw Exception('Failed to deduct stock for order ${order.orderId}');
      }

      // 3. Send confirmation notifications
      await _sendOrderConfirmationNotification(order);

      return true;
    } catch (e) {
      print('❌ Error confirming order: $e');

      // Rollback if needed
      await _stockRepository.processOrderStockRestoration(order);
      return false;
    }
  }

  // ✅ Process order cancellation with stock restoration
  Future<bool> cancelOrder(OrderModel order) async {
    try {
      // 1. Restore stock
      final stockRestored = await _stockRepository.processOrderStockRestoration(order);

      if (!stockRestored) {
        throw Exception('Failed to restore stock for order ${order.orderId}');
      }

      // 3. Send cancellation notifications
      await _sendOrderCancellationNotification(order);

      return true;
    } catch (e) {
      print('❌ Error cancelling order: $e');
      return false;
    }
  }

  Future<void> _sendOrderConfirmationNotification(OrderModel order) async {
    // Your existing notification logic
  }

  Future<void> _sendOrderCancellationNotification(OrderModel order) async {
    // Your existing notification logic
  }
}
