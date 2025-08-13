import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:raising_india/features/services/review_repository.dart';
import 'package:raising_india/models/review_model.dart';

part 'admin_review_event.dart';
part 'admin_review_state.dart';
class AdminReviewBloc extends Bloc<AdminReviewEvent, AdminReviewState> {
  final ReviewRepository _reviewRepository;
  StreamSubscription<List<ReviewModel>>? _reviewsSubscription;

  AdminReviewBloc({required ReviewRepository reviewRepository})
      : _reviewRepository = reviewRepository,
        super(AdminReviewInitial()) {

    on<LoadAllReviews>(_onLoadAllReviews);
    on<FilterReviews>(_onFilterReviews);
    on<SearchReviews>(_onSearchReviews);
    on<SortReviews>(_onSortReviews);
    on<RefreshReviews>(_onRefreshReviews);
  }

  Future<void> _onLoadAllReviews(
      LoadAllReviews event,
      Emitter<AdminReviewState> emit,
      ) async {
    emit(AdminReviewLoading());

    try {
      await _reviewsSubscription?.cancel();

      // Load review summary
      final summary = await _reviewRepository.getReviewSummary();

      // Stream all reviews
      await emit.forEach<List<ReviewModel>>(
        _reviewRepository.getAllReviews(), // You'll need to add this method
        onData: (reviews) => AdminReviewLoaded(
          reviews: reviews,
          filteredReviews: reviews,
          summary: summary,
        ),
        onError: (error, _) => AdminReviewError('Failed to load reviews: $error'),
      );
    } catch (e) {
      emit(AdminReviewError('Failed to load reviews: $e'));
    }
  }

  void _onFilterReviews(
      FilterReviews event,
      Emitter<AdminReviewState> emit,
      ) {
    if (state is AdminReviewLoaded) {
      final currentState = state as AdminReviewLoaded;
      List<ReviewModel> filteredReviews;

      switch (event.filter) {
        case 'high_rating':
          filteredReviews = currentState.reviews
              .where((r) => (r.serviceRating + r.productRating) / 2 >= 4.0)
              .toList();
          break;
        case 'low_rating':
          filteredReviews = currentState.reviews
              .where((r) => (r.serviceRating + r.productRating) / 2 <= 2.0)
              .toList();
          break;
        case 'recent':
          final recentDate = DateTime.now().subtract(const Duration(days: 7));
          filteredReviews = currentState.reviews
              .where((r) => r.createdAt.isAfter(recentDate))
              .toList();
          break;
        default:
          filteredReviews = currentState.reviews;
      }

      emit(currentState.copyWith(
        filteredReviews: filteredReviews,
        currentFilter: event.filter,
      ));
    }
  }

  void _onSearchReviews(
      SearchReviews event,
      Emitter<AdminReviewState> emit,
      ) {
    if (state is AdminReviewLoaded) {
      final currentState = state as AdminReviewLoaded;

      if (event.query.isEmpty) {
        emit(currentState.copyWith(
          filteredReviews: currentState.reviews,
          searchQuery: event.query,
        ));
      } else {
        final filteredReviews = currentState.reviews.where((review) {
          return review.userName.toLowerCase().contains(event.query.toLowerCase()) ||
              review.serviceReview.toLowerCase().contains(event.query.toLowerCase()) ||
              review.productReview.toLowerCase().contains(event.query.toLowerCase()) ||
              review.orderId.toLowerCase().contains(event.query.toLowerCase());
        }).toList();

        emit(currentState.copyWith(
          filteredReviews: filteredReviews,
          searchQuery: event.query,
        ));
      }
    }
  }

  void _onSortReviews(
      SortReviews event,
      Emitter<AdminReviewState> emit,
      ) {
    if (state is AdminReviewLoaded) {
      final currentState = state as AdminReviewLoaded;
      final sortedReviews = List<ReviewModel>.from(currentState.filteredReviews);

      sortedReviews.sort((a, b) {
        int comparison;
        switch (event.sortBy) {
          case 'service_rating':
            comparison = a.serviceRating.compareTo(b.serviceRating);
            break;
          case 'product_rating':
            comparison = a.productRating.compareTo(b.productRating);
            break;
          case 'user_name':
            comparison = a.userName.compareTo(b.userName);
            break;
          case 'date':
          default:
            comparison = a.createdAt.compareTo(b.createdAt);
        }
        return event.ascending ? comparison : -comparison;
      });

      emit(currentState.copyWith(
        filteredReviews: sortedReviews,
        sortBy: event.sortBy,
        ascending: event.ascending,
      ));
    }
  }

  void _onRefreshReviews(
      RefreshReviews event,
      Emitter<AdminReviewState> emit,
      ) {
    add(LoadAllReviews());
  }

  @override
  Future<void> close() {
    _reviewsSubscription?.cancel();
    return super.close();
  }
}

