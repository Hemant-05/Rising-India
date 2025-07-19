part of 'order_bloc.dart';

@immutable
sealed class OrderState {}

final class OrderInitial extends OrderState {}

final class OrderLoadingState extends OrderState{}

final class OrderLoadedState extends OrderState{
  final List<OrderModel> orderList;
  OrderLoadedState({required this.orderList});
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
