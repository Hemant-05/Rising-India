// lib/screens/user_order_tracking_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raising_india/models/order_model.dart';

class UserOrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const UserOrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final order = OrderModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

        return Scaffold(
          appBar: AppBar(title: Text('Track Order')),
          body: Column(
            children: [
              // Order Status Timeline
              _buildStatusTimeline(order.orderStatus),

              // Payment Status
              Card(
                margin: const EdgeInsets.all(16),
                child: ListTile(
                  leading: Icon(
                    _getPaymentIcon(order.paymentStatus),
                    color: _getPaymentColor(order.paymentStatus),
                  ),
                  title: Text('Payment Status'),
                  subtitle: Text(_getPaymentText(order.paymentStatus)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final statuses = ['created', 'confirmed', 'preparing', 'dispatched', 'delivered'];
    final statusNames = ['Order Placed', 'Confirmed', 'Preparing', 'Dispatched', 'Delivered'];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...statuses.asMap().entries.map((entry) {
              final index = entry.key;
              final status = entry.value;
              final isActive = statuses.indexOf(currentStatus) >= index;

              return Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.green : Colors.grey.shade300,
                    ),
                    child: isActive ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    statusNames[index],
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String status) {
    switch (status) {
      case 'paid': return Icons.check_circle;
      case 'pending': return Icons.hourglass_empty;
      case 'failed': return Icons.error;
      case 'refunded': return Icons.refresh;
      default: return Icons.info;
    }
  }

  Color _getPaymentColor(String status) {
    switch (status) {
      case 'paid': return Colors.green;
      case 'pending': return Colors.orange;
      case 'failed': return Colors.red;
      case 'refunded': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _getPaymentText(String status) {
    switch (status) {
      case 'paid': return 'Payment completed';
      case 'pending': return 'Payment pending';
      case 'failed': return 'Payment failed';
      case 'refunded': return 'Payment refunded';
      default: return status;
    }
  }
}
