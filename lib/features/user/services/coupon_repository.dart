import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raising_india/models/coupon_model.dart';

abstract class CouponRepository {
  Stream<List<CouponModel>> getUserCoupons(String userId);
  Future<void> generateCashbackCoupon(String userId, String orderId, double orderTotal);
  Future<void> useCoupon(String userId, String couponId);
  Future<CouponModel?> validateCoupon(String userId, String couponCode);
  Future<void> updateExpiredCoupons(String userId);
  // New methods for coupon usage
  Future<CouponModel?> validateAndReserveCoupon(String userId, String couponCode);
  Future<void> applyCouponToOrder(String userId, String couponId, String orderId);
  Future<void> releaseCouponReservation(String userId, String couponId);
}

class CouponRepositoryImpl implements CouponRepository {
  final FirebaseFirestore _firestore;

  CouponRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<CouponModel>> getUserCoupons(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('coupons')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CouponModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  @override
  Future<void> generateCashbackCoupon(String userId, String orderId, double orderTotal) async {
    try {
      const int cashbackPercent = 5;
      final double cashbackValue = orderTotal * cashbackPercent / 100;
      final String couponCode = _generateCouponCode(orderId);

      final DateTime now = DateTime.now();
      final DateTime expiresAt = now.add(const Duration(hours: 48));

      final coupon = CouponModel(
        id: '',
        code: couponCode,
        discountPercent: cashbackPercent,
        createdAt: now,
        expiresAt: expiresAt,
        status: 'unused',
        orderId: orderId,
        value: cashbackValue,
        type: 'cashback',
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('coupons')
          .add(coupon.toMap());

      print('✅ Cashback coupon generated: $couponCode for ₹$cashbackValue');
    } catch (e) {
      print('❌ Error generating cashback coupon: $e');
      throw Exception('Failed to generate cashback coupon: $e');
    }
  }

  @override
  Future<void> useCoupon(String userId, String couponId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('coupons')
          .doc(couponId)
          .update({
        'status': 'used',
        'usedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to use coupon: $e');
    }
  }

  @override
  Future<CouponModel?> validateCoupon(String userId, String couponCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('coupons')
          .where('code', isEqualTo: couponCode)
          .where('status', isEqualTo: 'unused')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final coupon = CouponModel.fromMap(doc.data(), doc.id);

        if (coupon.isValid) {
          return coupon;
        } else if (coupon.isExpired) {
          // Mark as expired
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('coupons')
              .doc(doc.id)
              .update({'status': 'expired'});
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to validate coupon: $e');
    }
  }

  @override
  Future<void> updateExpiredCoupons(String userId) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('coupons')
          .where('status', isEqualTo: 'unused')
          .get();

      final batch = _firestore.batch();

      for (var doc in querySnapshot.docs) {
        final coupon = CouponModel.fromMap(doc.data(), doc.id);
        if (coupon.expiresAt.isBefore(now)) {
          batch.update(doc.reference, {'status': 'expired'});
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error updating expired coupons: $e');
    }
  }

  String _generateCouponCode(String orderId) {
    final prefix = 'CB';
    final suffix = orderId.substring(0, 6).toUpperCase();
    return '$prefix$suffix';
  }

  @override
  Future<CouponModel?> validateAndReserveCoupon(String userId, String couponCode) async {
    try {
      // Use transaction to atomically validate and reserve coupon
      return await _firestore.runTransaction<CouponModel?>((transaction) async {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('coupons')
            .where('code', isEqualTo: couponCode)
            .where('status', isEqualTo: 'unused')
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw Exception('Invalid coupon code');
        }

        final doc = querySnapshot.docs.first;
        final coupon = CouponModel.fromMap(doc.data(), doc.id);

        // Check if coupon is expired
        if (coupon.isExpired) {
          // Mark as expired
          transaction.update(doc.reference, {
            'status': 'expired',
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
          throw Exception('Coupon has expired');
        }

        // Reserve coupon for 10 minutes
        final reservationExpiry = DateTime.now().add(const Duration(minutes: 10));
        transaction.update(doc.reference, {
          'status': 'reserved',
          'reservedAt': Timestamp.fromDate(DateTime.now()),
          'reservationExpiry': Timestamp.fromDate(reservationExpiry),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });

        return coupon.copyWith(status: 'reserved');
      });
    } catch (e) {
      throw Exception('Failed to validate coupon: $e');
    }
  }

  @override
  Future<void> applyCouponToOrder(String userId, String couponId, String orderId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final couponRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('coupons')
            .doc(couponId);

        final couponDoc = await transaction.get(couponRef);

        if (!couponDoc.exists) {
          throw Exception('Coupon not found');
        }

        final couponData = couponDoc.data()!;

        if (couponData['status'] != 'reserved') {
          throw Exception('Coupon is not reserved or already used');
        }

        // Mark coupon as used
        transaction.update(couponRef, {
          'status': 'used',
          'usedAt': Timestamp.fromDate(DateTime.now()),
          'usedForOrderId': orderId,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Failed to apply coupon: $e');
    }
  }

  @override
  Future<void> releaseCouponReservation(String userId, String couponId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final couponRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('coupons')
            .doc(couponId);

        final couponDoc = await transaction.get(couponRef);

        if (couponDoc.exists && couponDoc.data()!['status'] == 'reserved') {
          transaction.update(couponRef, {
            'status': 'unused',
            'reservedAt': FieldValue.delete(),
            'reservationExpiry': FieldValue.delete(),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
        }
      });
    } catch (e) {
      print('Error releasing coupon reservation: $e');
    }
  }
}
