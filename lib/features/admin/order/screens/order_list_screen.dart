import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/order/OrderFilterType.dart';
import 'package:raising_india/features/admin/order/admin_order_card.dart';
import 'package:raising_india/features/admin/order/bloc/order_list/order_list_bloc.dart';
import 'package:raising_india/features/admin/services/order_repository.dart';

class OrderListScreen extends StatelessWidget {
  final String title;
  final OrderFilterType orderType;

  const OrderListScreen({
    super.key,
    required this.title,
    required this.orderType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderListBloc(
        FirebaseFirestore.instance,
        context.read<OrderRepository>(),
      )..add(LoadOrders(orderType)),
      child: OrderListView(title: title, orderType: orderType),
    );
  }
}

class OrderListView extends StatefulWidget {
  final String title;
  final OrderFilterType orderType;

  const OrderListView({
    super.key,
    required this.title,
    required this.orderType,
  });

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<OrderListBloc>().add(LoadMoreOrders());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text(widget.title,style: simple_text_style(fontSize: 20),),
            const Spacer(),
          ],
        ),
      ),
      body: BlocBuilder<OrderListBloc, OrderListState>(
        builder: (context, state) {
          if (state.loading && state.orders.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: AppColour.primary),
            );
          }
          if (state.error != null && state.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.error}'),
                  ElevatedButton(
                    style: elevated_button_style(),
                    onPressed: () =>
                        context.read<OrderListBloc>().add(RefreshOrders()),
                    child: Text(
                      'Retry',
                      style: simple_text_style(color: AppColour.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No ${widget.title.toLowerCase()} found'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColour.primary,
            backgroundColor: AppColour.white,
            onRefresh: () async {
              context.read<OrderListBloc>().add(RefreshOrders());
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length + (state.loadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= state.orders.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final orderWithProducts = state.orders[index];
                return AdminOrderCard(
                  orderWithProducts: orderWithProducts,
                  showTime: widget.orderType == OrderFilterType.today,
                  isRunning: widget.orderType == OrderFilterType.running,
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
