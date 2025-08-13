// lib/repositories/review_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raising_india/models/review_model.dart';

abstract class ReviewRepository {
  Future<void> submitReview(ReviewModel review);
  Future<ReviewModel?> getOrderReview(String orderId);
  Future<bool> hasUserReviewedOrder(String userId, String orderId);
  Future<ReviewSummaryModel> getReviewSummary();
  Future<void> updateReview(ReviewModel review);
  Stream<List<ReviewModel>> getRecentReviews({int limit = 10});
  Stream<List<ReviewModel>> getAllReviews();
  Future<List<ReviewModel>> getReviewsByDateRange(DateTime start, DateTime end);
}

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore _firestore;

  ReviewRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> submitReview(ReviewModel review) async {
    try {
      // ✅ Check if review already exists for this order
      final existingReview = await getOrderReview(review.orderId);

      if (existingReview != null) {
        // Update existing review instead of creating new one
        await updateReview(review.copyWith(id: existingReview.id));
      } else {
        // Create new review
        await _firestore.collection('reviews').add(review.toMap());

        // Update order with review flag
        await _firestore.collection('orders').doc(review.orderId).update({
          'hasReview': true,
          'reviewedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      print('✅ Review submitted successfully');
    } catch (e) {
      print('❌ Error submitting review: $e');
      throw Exception('Failed to submit review: $e');
    }
  }

  @override
  Future<void> updateReview(ReviewModel review) async {
    try {
      await _firestore.collection('reviews').doc(review.id).update({
        'serviceRating': review.serviceRating,
        'productRating': review.productRating,
        'serviceReview': review.serviceReview,
        'productReview': review.productReview,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ Review updated successfully');
    } catch (e) {
      print('❌ Error updating review: $e');
      throw Exception('Failed to update review: $e');
    }
  }

  @override
  Future<ReviewModel?> getOrderReview(String orderId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return ReviewModel.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get review: $e');
    }
  }

  @override
  Future<bool> hasUserReviewedOrder(String userId, String orderId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ReviewSummaryModel> getReviewSummary() async {
    try {
      final querySnapshot = await _firestore.collection('reviews').get();

      if (querySnapshot.docs.isEmpty) {
        return ReviewSummaryModel(
          averageServiceRating: 0.0,
          averageProductRating: 0.0,
          totalReviews: 0,
          serviceRatingDistribution: {},
          productRatingDistribution: {},
        );
      }

      double totalServiceRating = 0.0;
      double totalProductRating = 0.0;
      Map<int, int> serviceDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      Map<int, int> productDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final serviceRating = (data['serviceRating'] ?? 0).toDouble();
        final productRating = (data['productRating'] ?? 0).toDouble();

        totalServiceRating += serviceRating;
        totalProductRating += productRating;

        serviceDistribution[serviceRating.round()] =
            (serviceDistribution[serviceRating.round()] ?? 0) + 1;
        productDistribution[productRating.round()] =
            (productDistribution[productRating.round()] ?? 0) + 1;
      }

      return ReviewSummaryModel(
        averageServiceRating: totalServiceRating / querySnapshot.docs.length,
        averageProductRating: totalProductRating / querySnapshot.docs.length,
        totalReviews: querySnapshot.docs.length,
        serviceRatingDistribution: serviceDistribution,
        productRatingDistribution: productDistribution,
      );
    } catch (e) {
      throw Exception('Failed to get review summary: $e');
    }
  }

  @override
  Stream<List<ReviewModel>> getRecentReviews({int limit = 10}) {
    return _firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  @override
  Stream<List<ReviewModel>> getAllReviews() {
    return _firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  @override
  Future<List<ReviewModel>> getReviewsByDateRange(DateTime start, DateTime end) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reviews by date range: $e');
    }
  }
}
