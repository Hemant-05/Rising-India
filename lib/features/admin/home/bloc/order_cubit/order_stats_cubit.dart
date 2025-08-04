import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/models/order_model.dart';

part 'order_stats_state.dart';

class OrderStatsCubit extends Cubit<OrderStatsState> {
  final FirebaseFirestore firestore;
  StreamSubscription? _sub;

  OrderStatsCubit(this.firestore) : super(OrderStatsState.initial()) {
    _init();
  }

  void _init() {
    _sub?.cancel();
    _sub = firestore.collection('orders').snapshots().listen((snap) {
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      int running = 0, cancelled = 0, delivered = 0, todayCount = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final model = OrderModel.fromMap(data..['orderId'] = doc.id);

        switch (model.orderStatus) {
          case 'cancelled':
            cancelled++;
            break;
          case 'delivered':
            delivered++;
            break;
          default:
            running++;
        }
        if (DateFormat('yyyy-MM-dd').format(model.createdAt) == today) {
          todayCount++;
        }
      }
      emit(
        OrderStatsState(
          runningOrders: running,
          cancelledOrders: cancelled,
          deliveredOrders: delivered,
          todayOrders: todayCount,
          totalOrders: snap.size,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
