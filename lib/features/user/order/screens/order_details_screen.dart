import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/models/order_model.dart';

// For illustration, your models might differ slightly in names.
class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.orderStatus);
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Order Details', style: simple_text_style(fontSize: 20)),
            const Spacer(),
          ],
        ),
        backgroundColor: AppColour.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Order Status & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _statusText(order.orderStatus),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(DateFormat('MMM d, h:mm a').format(order.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          if (order.orderStatus == 'cancelled' && order.cancellationReason != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.red.shade400, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cancelled: ${order.cancellationReason}',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 18),
          // Payment Status
          Row(
            children: [
              Icon(order.paymentMethod == "prepaid"
                  ? Icons.credit_card
                  : Icons.money,
                  color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              Text(
                order.paymentMethod == "prepaid" ? "Prepaid" : "COD",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 14),
              Icon(
                _paymentStatusIcon(order.paymentStatus),
                size: 18,
                color: _paymentStatusColor(order.paymentStatus),
              ),
              const SizedBox(width: 5),
              Text(
                _paymentStatusText(order.paymentStatus),
                style: TextStyle(
                    color: _paymentStatusColor(order.paymentStatus),
                    fontSize: 13),
              ),
            ],
          ),
          const Divider(height: 32),
          // Items List
          Text('Items', style: Theme.of(context).textTheme.titleMedium),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, __) => const Divider(height: 12),
            itemBuilder: (context, i) {
              final product = order.items[i];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product["image"] ?? "",
                      width: 48, height: 48, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      product["name"] ?? "Unknown",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Text("x${product["quantity"]}", style: const TextStyle(fontSize: 15, color: Colors.grey)),
                ],
              );
            },
          ),
          const Divider(height: 32),
          // Price Details
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Order Summary', style: Theme.of(context).textTheme.titleMedium),
          ),
          _orderSummaryRow("Subtotal", order.subtotal),
          _orderSummaryRow("Delivery Fee", order.deliveryFee),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("₹${order.total.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 30),
          // Address
          Text('Delivery Address', style: Theme.of(context).textTheme.titleMedium),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
                color: Colors.grey[100], borderRadius: BorderRadius.circular(7)),
            child: Text(
              order.address.fullAddress,  // make sure your DeliveryAddress has a `fullAddress` getter
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          // Transaction & timestamps (optional)
          if (order.transactionId != null)
            _keyValueRow("Transaction ID", order.transactionId!),
          if (order.paidAt != null)
            _keyValueRow("Paid At", DateFormat('MMM d, h:mm a').format(order.paidAt!)),
          if (order.deliveredAt != null)
            _keyValueRow("Delivered At", DateFormat('MMM d, h:mm a').format(order.deliveredAt!)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- UI Helpers ---
  Widget _orderSummaryRow(String label, double value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black87)),
        Text("₹${value.toStringAsFixed(2)}", style: const TextStyle(color: Colors.black54, fontSize: 14)),
      ],
    ),
  );

  Widget _keyValueRow(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black, fontSize: 13))),
        ],
      ));
}

// --- Helper utils for status/icons/text/colors ---
String _statusText(String s) {
  switch (s) {
    case "created": return "Order Placed";
    case "confirmed": return "Order Confirmed";
    case "preparing": return "Preparing";
    case "dispatched": return "Out For Delivery";
    case "delivered": return "Delivered";
    case "cancelled": return "Cancelled";
    default: return s;
  }
}

Color _statusColor(String s) {
  switch (s) {
    case "delivered": return Colors.green;
    case "cancelled": return Colors.red;
    case "preparing": return Colors.orange;
    case "dispatched": return Colors.blue;
    case "confirmed": return Colors.teal;
    default: return Colors.grey;
  }
}

IconData _paymentStatusIcon(String s) {
  switch (s) {
    case "paid": return Icons.check_circle;
    case "pending": return Icons.hourglass_empty;
    case "failed": return Icons.cancel;
    case "refunded": return Icons.refresh;
    default: return Icons.info;
  }
}

Color _paymentStatusColor(String s) {
  switch (s) {
    case "paid": return Colors.green;
    case "pending": return Colors.orange;
    case "failed": return Colors.red;
    case "refunded": return Colors.blueGrey;
    default: return Colors.grey;
  }
}

String _paymentStatusText(String s) {
  switch (s) {
    case "paid": return "Paid";
    case "pending": return "Pending";
    case "failed": return "Failed";
    case "refunded": return "Refunded";
    default: return s;
  }
}
