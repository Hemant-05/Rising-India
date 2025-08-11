import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id;
  final String code;
  final int discountPercent;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String status; // 'unused', 'used', 'expired'
  final String orderId;
  final double value;
  final String type; // 'cashback', 'promotional', etc.

  CouponModel({
    required this.id,
    required this.code,
    required this.discountPercent,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    required this.orderId,
    required this.value,
    this.type = 'cashback',
  });

  factory CouponModel.fromMap(Map<String, dynamic> data, String id) {
    return CouponModel(
      id: id,
      code: data['code'] ?? '',
      discountPercent: data['discountPercent'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'unused',
      orderId: data['orderId'] ?? '',
      value: (data['value'] ?? 0).toDouble(),
      type: data['type'] ?? 'cashback',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discountPercent': discountPercent,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'status': status,
      'orderId': orderId,
      'value': value,
      'type': type,
    };
  }

  CouponModel copyWith({
    String? id,
    String? code,
    int? discountPercent,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? status,
    String? orderId,
    double? value,
    String? type,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      discountPercent: discountPercent ?? this.discountPercent,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      value: value ?? this.value,
      type: type ?? this.type,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isUsed => status == 'used';
  bool get isValid => status == 'unused' && !isExpired;
}
