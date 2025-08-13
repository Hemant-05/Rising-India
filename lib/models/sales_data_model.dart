// lib/models/sales_data_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesDataModel {
  final DateTime date;
  final double amount;
  final int ordersCount;

  SalesDataModel({
    required this.date,
    required this.amount,
    required this.ordersCount,
  });

  factory SalesDataModel.fromMap(Map<String, dynamic> data) {
    return SalesDataModel(
      date: (data['date'] as Timestamp).toDate(),
      amount: (data['amount'] ?? 0).toDouble(),
      ordersCount: data['ordersCount'] ?? 0,
    );
  }
}

class SalesAnalyticsModel {
  final List<SalesDataModel> dailySales;
  final List<SalesDataModel> weeklySales;
  final List<SalesDataModel> monthlySales;
  final double totalRevenue;
  final double averageOrderValue;
  final int totalOrders;
  final double growthPercentage;

  SalesAnalyticsModel({
    required this.dailySales,
    required this.weeklySales,
    required this.monthlySales,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.totalOrders,
    required this.growthPercentage,
  });
}

enum SalesTimePeriod { day, week, month }
