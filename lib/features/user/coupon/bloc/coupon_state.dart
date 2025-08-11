part of 'coupon_bloc.dart';

abstract class CouponState {}

class CouponInitial extends CouponState {}

class CouponLoading extends CouponState {}

class CouponLoaded extends CouponState {
  final List<CouponModel> coupons;
  final List<CouponModel> filteredCoupons;
  final String currentFilter;

  CouponLoaded({
    required this.coupons,
    required this.filteredCoupons,
    this.currentFilter = 'all',
  });

  CouponLoaded copyWith({
    List<CouponModel>? coupons,
    List<CouponModel>? filteredCoupons,
    String? currentFilter,
  }) {
    return CouponLoaded(
      coupons: coupons ?? this.coupons,
      filteredCoupons: filteredCoupons ?? this.filteredCoupons,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class CouponValidated extends CouponState {
  final CouponModel? coupon;
  final String message;

  CouponValidated({this.coupon, required this.message});
}

class CouponUsed extends CouponState {
  final String message;
  CouponUsed(this.message);
}

class CouponError extends CouponState {
  final String message;
  CouponError(this.message);
}

class CashbackGenerated extends CouponState {
  final String message;
  CashbackGenerated(this.message);
}

class CouponAppliedToCheckout extends CouponState {
  final CouponModel coupon;
  final double originalTotal;
  final double discountAmount;
  final double finalTotal;

  CouponAppliedToCheckout({
    required this.coupon,
    required this.originalTotal,
    required this.discountAmount,
    required this.finalTotal,
  });
}

class CouponApplicationCancelled extends CouponState {
  final String message;
  CouponApplicationCancelled(this.message);
}
