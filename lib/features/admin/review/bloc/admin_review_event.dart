part of 'admin_review_bloc.dart';

// lib/blocs/admin_review/admin_review_event.dart
abstract class AdminReviewEvent {}

class LoadAllReviews extends AdminReviewEvent {}

class FilterReviews extends AdminReviewEvent {
  final String filter; // 'all', 'high_rating', 'low_rating', 'recent'
  FilterReviews(this.filter);
}

class SearchReviews extends AdminReviewEvent {
  final String query;
  SearchReviews(this.query);
}

class SortReviews extends AdminReviewEvent {
  final String sortBy; // 'date', 'service_rating', 'product_rating', 'user_name'
  final bool ascending;

  SortReviews({
    required this.sortBy,
    this.ascending = false,
  });
}

class LoadReviewDetails extends AdminReviewEvent {
  final String reviewId;
  LoadReviewDetails(this.reviewId);
}

class RefreshReviews extends AdminReviewEvent {}
