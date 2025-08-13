part of 'admin_review_bloc.dart';

abstract class AdminReviewState {}

class AdminReviewInitial extends AdminReviewState {}

class AdminReviewLoading extends AdminReviewState {}

class AdminReviewLoaded extends AdminReviewState {
  final List<ReviewModel> reviews;
  final List<ReviewModel> filteredReviews;
  final ReviewSummaryModel summary;
  final String currentFilter;
  final String searchQuery;
  final String sortBy;
  final bool ascending;

  AdminReviewLoaded({
    required this.reviews,
    required this.filteredReviews,
    required this.summary,
    this.currentFilter = 'all',
    this.searchQuery = '',
    this.sortBy = 'date',
    this.ascending = false,
  });

  AdminReviewLoaded copyWith({
    List<ReviewModel>? reviews,
    List<ReviewModel>? filteredReviews,
    ReviewSummaryModel? summary,
    String? currentFilter,
    String? searchQuery,
    String? sortBy,
    bool? ascending,
  }) {
    return AdminReviewLoaded(
      reviews: reviews ?? this.reviews,
      filteredReviews: filteredReviews ?? this.filteredReviews,
      summary: summary ?? this.summary,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

class AdminReviewError extends AdminReviewState {
  final String message;
  AdminReviewError(this.message);
}
