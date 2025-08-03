// lib/screens/admin_order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raising_india/features/admin/order/bloc/admin_order_details_cubit.dart';
import 'package:raising_india/models/order_model.dart';

class AdminOrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const AdminOrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminOrderDetailsCubit(orderId),
      child: BlocBuilder<AdminOrderDetailsCubit, AdminOrderDetailsState>(
        builder: (context, state) {
          if (state.loading) return Scaffold(body: Center(child: CircularProgressIndicator()));
          if (state.error != null) return Scaffold(body: Center(child: Text(state.error!)));

          final order = state.order!;
          return Scaffold(
            appBar: AppBar(title: Text('Order #${orderId.substring(0, 6)}')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Order Status Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Status', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: order.orderStatus,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'created', child: Text('Order Placed')),
                            DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                            DropdownMenuItem(value: 'preparing', child: Text('Preparing')),
                            DropdownMenuItem(value: 'dispatched', child: Text('Dispatched')),
                            DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                            DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              context.read<AdminOrderDetailsCubit>().updateOrderStatus(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Payment Status Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Status', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: order.paymentStatus,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'paid', child: Text('Paid')),
                            DropdownMenuItem(value: 'failed', child: Text('Failed')),
                            DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              context.read<AdminOrderDetailsCubit>().updatePaymentStatus(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Order Details (items, address, etc.)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Items', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        ...order.items.map((item) => ListTile(
                          leading: Image.network(item['image'] ?? '', width: 40, height: 40, fit: BoxFit.cover),
                          title: Text(item['name'] ?? 'Unknown'),
                          trailing: Text('x${item['quantity']}'),
                        )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('₹${order.total}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}