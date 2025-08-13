part of 'review_bloc.dart';

// lib/blocs/review/review_event.dart
abstract class ReviewEvent {}

class LoadOrderForReview extends ReviewEvent {
  final String orderId;
  LoadOrderForReview(this.orderId);
}

class UpdateServiceRating extends ReviewEvent {
  final double rating;
  UpdateServiceRating(this.rating);
}

class UpdateProductRating extends ReviewEvent {
  final double rating;
  UpdateProductRating(this.rating);
}

class UpdateServiceReview extends ReviewEvent {
  final String review;
  UpdateServiceReview(this.review);
}

class UpdateProductReview extends ReviewEvent {
  final String review;
  UpdateProductReview(this.review);
}

class SubmitReview extends ReviewEvent {
  final String orderId;
  final String userId;
  final String userName;
  final List<String> productIds;

  SubmitReview({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.productIds,
  });
}

class UpdateExistingReview extends ReviewEvent {
  final String reviewId;
  final String orderId;
  final String userId;
  final String userName;
  final List<String> productIds;

  UpdateExistingReview({
    required this.reviewId,
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.productIds,
  });
}

class CheckOrderReviewStatus extends ReviewEvent {
  final String userId;
  final String orderId;

  CheckOrderReviewStatus({
    required this.userId,
    required this.orderId,
  });
}
