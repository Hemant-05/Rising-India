part of 'order_list_bloc.dart';

abstract class OrderListEvent {}
class LoadOrders extends OrderListEvent {
  final OrderFilterType filterType;
  LoadOrders(this.filterType);
}
class LoadMoreOrders extends OrderListEvent {}
class RefreshOrders extends OrderListEvent {}