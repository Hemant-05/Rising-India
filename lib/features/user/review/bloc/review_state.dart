part of 'review_bloc.dart';

abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class OrderLoadedForReview extends ReviewState {
  final OrderModel order;
  final double serviceRating;
  final double productRating;
  final String serviceReview;
  final String productReview;
  final bool hasExistingReview;
  final String? existingReviewId;

  OrderLoadedForReview({
    required this.order,
    this.serviceRating = 0.0,
    this.productRating = 0.0,
    this.serviceReview = '',
    this.productReview = '',
    this.hasExistingReview = false,
    this.existingReviewId,
  });

  OrderLoadedForReview copyWith({
    OrderModel? order,
    double? serviceRating,
    double? productRating,
    String? serviceReview,
    String? productReview,
    bool? hasExistingReview,
    String? existingReviewId,
  }) {
    return OrderLoadedForReview(
      order: order ?? this.order,
      serviceRating: serviceRating ?? this.serviceRating,
      productRating: productRating ?? this.productRating,
      serviceReview: serviceReview ?? this.serviceReview,
      productReview: productReview ?? this.productReview,
      hasExistingReview: hasExistingReview ?? this.hasExistingReview,
      existingReviewId: existingReviewId ?? this.existingReviewId,
    );
  }
}

class ReviewSubmitting extends ReviewState {}

class ReviewSubmitted extends ReviewState {
  final String message;
  ReviewSubmitted(this.message);
}

class ReviewError extends ReviewState {
  final String message;
  ReviewError(this.message);
}
