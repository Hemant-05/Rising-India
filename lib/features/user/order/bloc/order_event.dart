part of 'order_bloc.dart';

@immutable
sealed class OrderEvent {}

class InitialEvent extends OrderEvent{}

class LoadUserCompletedOrderEvent extends OrderEvent{}

class LoadUserOngoingOrderEvent extends OrderEvent{}

class CancelOrderEvent extends OrderEvent{
  final String orderId;
  final String cancellationReason;
  final String payStatus;
  CancelOrderEvent({required this.orderId, required this.cancellationReason,required this.payStatus});
}

class PlaceOrderEvent extends OrderEvent{
  final OrderModel model;
  PlaceOrderEvent({required this.model});
}

class GetOrderByIdEvent extends OrderEvent{
  final String orderId;
  GetOrderByIdEvent({required this.orderId});
}


