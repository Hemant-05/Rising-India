part of 'coupon_bloc.dart';

// lib/blocs/coupon/coupon_event.dart
abstract class CouponEvent {}

class LoadUserCoupons extends CouponEvent {
  LoadUserCoupons();
}

class UseCoupon extends CouponEvent {
  final String userId;
  final String couponId;
  UseCoupon({required this.userId, required this.couponId});
}

class ValidateCoupon extends CouponEvent {
  final String userId;
  final String couponCode;
  ValidateCoupon({required this.userId, required this.couponCode});
}

class FilterCoupons extends CouponEvent {
  final String filter; // 'all', 'unused', 'used', 'expired'
  FilterCoupons(this.filter);
}

class GenerateCashbackCoupon extends CouponEvent {
  final String userId;
  final String orderId;
  final double orderTotal;

  GenerateCashbackCoupon({
    required this.userId,
    required this.orderId,
    required this.orderTotal,
  });
}

class ApplyCouponToCheckout extends CouponEvent {
  final String userId;
  final String couponCode;
  final double orderTotal;

  ApplyCouponToCheckout({
    required this.userId,
    required this.couponCode,
    required this.orderTotal,
  });
}

class ConfirmCouponUsage extends CouponEvent {
  final String userId;
  final String couponId;
  final String orderId;

  ConfirmCouponUsage({
    required this.userId,
    required this.couponId,
    required this.orderId,
  });
}

class CancelCouponApplication extends CouponEvent {
  final String userId;
  final String couponId;

  CancelCouponApplication({
    required this.userId,
    required this.couponId,
  });
}