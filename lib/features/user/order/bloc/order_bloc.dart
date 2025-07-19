import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:raising_india/features/services/order_services.dart';
import 'package:raising_india/models/order_model.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderServices _services = OrderServices();
  OrderBloc() : super(OrderInitial()) {
    on<OrderEvent>((event, emit) {});
    on<LoadUserCompletedOrderEvent>((event, emit) async {
      emit(OrderLoadingState());
      final list = await _services.getUserCompletedOrders();
      emit(OrderLoadedState(orderList: list));
    });
    on<LoadUserOngoingOrderEvent>((event, emit) async {
      emit(OrderLoadingState());
      final list = await _services.getUserOnGoingOrders();
      emit(OrderLoadedState(orderList: list));
    });
    on<CancelOrderEvent>((event, emit) async {
      emit(OrderCancellingState());
      await _services.cancelOrder(event.orderId,event.cancellationReason);
      emit(OrderCancelledState());
    });
    on<PlaceOrderEvent>((event, emit) async {
      emit(OrderCreationState());
      await _services.placeOrder(event.model);
      emit(OrderCreatedState());
    });
    on<GetOrderByIdEvent>((event, emit) async {
      emit(OrderGettingByIdState());
      var model = await _services.getOrderById(event.orderId);
      emit(OrderGetByIdState(model: model));
    });
  }
}
