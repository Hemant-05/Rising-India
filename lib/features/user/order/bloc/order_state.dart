part of 'order_bloc.dart';

@immutable
sealed class OrderState {}

final class OrderInitial extends OrderState {}

final class OrderLoadingState extends OrderState{}

final class CompletedOrderLoadedState extends OrderState{
  final List<OrderModel> orderList;
  CompletedOrderLoadedState({required this.orderList});
}

final class OngoingOrderLoadedState extends OrderState{
  final List<OrderModel> orderList;
  OngoingOrderLoadedState({required this.orderList});
}

final class OrderErrorState extends OrderState{
  final String? error;
  OrderErrorState({this.error});
}

final class OrderCancellingState extends OrderState{}

final class OrderCancelledState extends OrderState {}

final class OrderCreationState extends OrderState{}

final class OrderCreatedState extends OrderState{}

final class OrderGettingByIdState extends OrderState{}

final class OrderGetByIdState extends OrderState{
  final OrderModel model;
  OrderGetByIdState({required this.model});
}
