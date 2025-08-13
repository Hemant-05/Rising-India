// lib/models/review_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String orderId;
  final String userId;
  final String userName;
  final double serviceRating;
  final double productRating;
  final String serviceReview;
  final String productReview;
  final DateTime createdAt;
  final List<String> productIds;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.serviceRating,
    required this.productRating,
    required this.serviceReview,
    required this.productReview,
    required this.createdAt,
    required this.productIds,
  });

  ReviewModel copyWith({
    String? id,
    String? orderId,
    String? userId,
    String? userName,
    double? serviceRating,
    double? productRating,
    String? serviceReview,
    String? productReview,
    DateTime? createdAt,
    List<String>? productIds,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      serviceRating: serviceRating ?? this.serviceRating,
      productRating: productRating ?? this.productRating,
      serviceReview: serviceReview ?? this.serviceReview,
      productReview: productReview ?? this.productReview,
      createdAt: createdAt ?? this.createdAt,
      productIds: productIds ?? this.productIds,
    );
  }

  factory ReviewModel.fromMap(Map<String, dynamic> data, String id) {
    return ReviewModel(
      id: id,
      orderId: data['orderId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      serviceRating: (data['serviceRating'] ?? 0).toDouble(),
      productRating: (data['productRating'] ?? 0).toDouble(),
      serviceReview: data['serviceReview'] ?? '',
      productReview: data['productReview'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      productIds: List<String>.from(data['productIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'serviceRating': serviceRating,
      'productRating': productRating,
      'serviceReview': serviceReview,
      'productReview': productReview,
      'createdAt': Timestamp.fromDate(createdAt),
      'productIds': productIds,
    };
  }
}

// Review Summary Model for displaying overall ratings
class ReviewSummaryModel {
  final double averageServiceRating;
  final double averageProductRating;
  final int totalReviews;
  final Map<int, int> serviceRatingDistribution;
  final Map<int, int> productRatingDistribution;

  ReviewSummaryModel({
    required this.averageServiceRating,
    required this.averageProductRating,
    required this.totalReviews,
    required this.serviceRatingDistribution,
    required this.productRatingDistribution,
  });
}
