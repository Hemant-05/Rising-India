import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/models/order_model.dart';

class OrderServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<OrderModel>> getAllDeliveredOrders() async {
    List<OrderModel> list = [];
    var res = await _firestore
        .collection('orders')
        .where('orderStatus', isEqualTo: OrderStatusDeliverd)
        .orderBy('createdAt', descending: false)
        .get();
    for (var element in res.docs) {
      final model = OrderModel.fromMap(element.data());
      list.add(model);
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<OrderModel>> getAllCancelledOrders() async {
    List<OrderModel> list = [];
    var res = await _firestore
        .collection('orders')
        .where('orderStatus', isEqualTo: OrderStatusCancelled)
        .orderBy('createdAt', descending: false)
        .get();
    for (var element in res.docs) {
      final model = OrderModel.fromMap(element.data());
      list.add(model);
    }

    return list;
  }

  Future<List<OrderModel>> getAllOnGoingOrders() async {
    List<OrderModel> list = [];
    var res = await _firestore
        .collection('orders')
        .where('orderStatus', isNotEqualTo: OrderStatusCancelled)
        .where('orderStatus', isNotEqualTo: OrderStatusDeliverd)
        .orderBy('createdAt', descending: false)
        .get();
    for (var element in res.docs) {
      final model = OrderModel.fromMap(element.data());
      list.add(model);
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<OrderModel>> getTodayAllOrders() async {
    List<OrderModel> list = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // strip time part
    var res = await _firestore.collection('orders').get();
    for (var element in res.docs) {
      final model = OrderModel.fromMap(element.data());
      if (today ==
          DateTime(
            model.createdAt.year,
            model.createdAt.month,
            model.createdAt.day,
          )) {
        list.add(model);
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<OrderModel>> getAllOrders() async {
    List<OrderModel> list = [];
    var res = await _firestore.collection('orders').get();
    for (var element in res.docs) {
      final model = OrderModel.fromMap(element.data());
      list.add(model);
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<OrderModel>> getUserCompletedOrders() async {
    List<OrderModel> list = [];
    final uid = _auth.currentUser!.uid;
    var res = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: uid)
        // .where('orderStatus', isEqualTo: OrderStatusDeliverd)
        .where('orderStatus', isEqualTo: OrderStatusCancelled)
        .get();
    for (var element in res.docs) {
      final model = OrderModel.fromMap(element.data());
      list.add(model);
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<OrderModel>> getUserOnGoingOrders() async {
    List<OrderModel> list = [];
    final uid = _auth.currentUser!.uid;
    var res = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .where('orderStatus', isNotEqualTo: OrderStatusDeliverd)
        .orderBy('createdAt', descending: false)
        .get();
    for (var element in res.docs) {
      final model = OrderModel.fromMap(element.data());
      list.add(model);
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> placeOrder(OrderModel model) async {
    await _firestore.collection('orders').doc(model.orderId).set(model.toMap());
  }

  Future<OrderModel> getOrderById(String orderId) async {
    OrderModel model;
    var res = await _firestore.collection('orders').doc(orderId).get();
    model = OrderModel.fromMap(res.data()!);
    return model;
  }

  Future<void> cancelOrder(String orderId, String cancellationReason) async {
    await _firestore.collection('orders').doc(orderId).update({
      'orderStatus': OrderStatusCancelled,
      'cancellationReason': cancellationReason,
    });
  }
}
