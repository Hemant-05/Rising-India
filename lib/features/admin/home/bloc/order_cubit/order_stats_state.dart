part of 'order_stats_cubit.dart';

class OrderStatsState {
  final int runningOrders;
  final int cancelledOrders;
  final int deliveredOrders;
  final int todayOrders;
  final int totalOrders;

  OrderStatsState({
    required this.runningOrders,
    required this.cancelledOrders,
    required this.deliveredOrders,
    required this.todayOrders,
    required this.totalOrders,
  });

  factory OrderStatsState.initial() => OrderStatsState(
    runningOrders: 0,
    cancelledOrders: 0,
    deliveredOrders: 0,
    todayOrders: 0,
    totalOrders: 0,
  );
}
