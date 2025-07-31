part of 'order_stats_cubit.dart';

class OrderStatsState {
  final int runningOrders;
  final int cancelledOrders;
  final int deliveredOrders;
  final int todaysOrders;
  final int totalOrders;
  final List<OrderModel> runningList; // for the latest running ones

  OrderStatsState({
    required this.runningOrders,
    required this.cancelledOrders,
    required this.deliveredOrders,
    required this.todaysOrders,
    required this.totalOrders,
    required this.runningList,
  });

  factory OrderStatsState.initial() => OrderStatsState(
    runningOrders: 0,
    cancelledOrders: 0,
    deliveredOrders: 0,
    todaysOrders: 0,
    totalOrders: 0,
    runningList: [],
  );
}
