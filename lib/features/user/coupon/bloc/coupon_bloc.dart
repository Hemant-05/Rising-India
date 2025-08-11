import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raising_india/features/user/services/coupon_repository.dart';
import 'package:raising_india/models/coupon_model.dart';

part 'coupon_event.dart';
part 'coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final CouponRepository _couponRepository;
  StreamSubscription<List<CouponModel>>? _couponsSubscription;

  CouponBloc({required CouponRepository couponRepository})
      : _couponRepository = couponRepository,
        super(CouponInitial()) {
    on<LoadUserCoupons>(_onLoadUserCoupons);
    on<UseCoupon>(_onUseCoupon);
    on<ValidateCoupon>(_onValidateCoupon);
    on<FilterCoupons>(_onFilterCoupons);
    on<GenerateCashbackCoupon>(_onGenerateCashbackCoupon);
    on<ApplyCouponToCheckout>(_onApplyCouponToCheckout);
    on<ConfirmCouponUsage>(_onConfirmCouponUsage);
    on<CancelCouponApplication>(_onCancelCouponApplication);
  }

  Future<void> _onLoadUserCoupons(LoadUserCoupons event, Emitter<CouponState> emit) async {
    emit(CouponLoading());

    try {
      // Update expired coupons first
      final userId = FirebaseAuth.instance.currentUser?.uid;
      await _couponRepository.updateExpiredCoupons(userId!);

      await _couponsSubscription?.cancel();

      await emit.forEach<List<CouponModel>>(
        _couponRepository.getUserCoupons(userId),
        onData: (coupons) => CouponLoaded(
          coupons: coupons,
          filteredCoupons: coupons,
        ),
        onError: (error, _) => CouponError('Failed to load coupons: $error'),
      );
    } catch (e) {
      emit(CouponError('Failed to load coupons: $e'));
    }
  }

  Future<void> _onUseCoupon(UseCoupon event, Emitter<CouponState> emit) async {
    try {
      await _couponRepository.useCoupon(event.userId, event.couponId);
      emit(CouponUsed('Coupon used successfully!'));
    } catch (e) {
      emit(CouponError('Failed to use coupon: $e'));
    }
  }

  Future<void> _onValidateCoupon(ValidateCoupon event, Emitter<CouponState> emit) async {
    try {
      final coupon = await _couponRepository.validateCoupon(event.userId, event.couponCode);

      if (coupon != null) {
        emit(CouponValidated(
          coupon: coupon,
          message: 'Coupon is valid! ₹${coupon.value.toStringAsFixed(2)} discount',
        ));
      } else {
        emit(CouponValidated(
          message: 'Invalid or expired coupon code',
        ));
      }
    } catch (e) {
      emit(CouponError('Failed to validate coupon: $e'));
    }
  }

  void _onFilterCoupons(FilterCoupons event, Emitter<CouponState> emit) {
    if (state is CouponLoaded) {
      final currentState = state as CouponLoaded;
      List<CouponModel> filteredCoupons;

      switch (event.filter) {
        case 'unused':
          filteredCoupons = currentState.coupons.where((c) => c.status == 'unused' && !c.isExpired).toList();
          break;
        case 'used':
          filteredCoupons = currentState.coupons.where((c) => c.status == 'used').toList();
          break;
        case 'expired':
          filteredCoupons = currentState.coupons.where((c) => c.status == 'expired' || c.isExpired).toList();
          break;
        default:
          filteredCoupons = currentState.coupons;
      }

      emit(currentState.copyWith(
        filteredCoupons: filteredCoupons,
        currentFilter: event.filter,
      ));
    }
  }

  Future<void> _onGenerateCashbackCoupon(GenerateCashbackCoupon event, Emitter<CouponState> emit) async {
    try {
      await _couponRepository.generateCashbackCoupon(
        event.userId,
        event.orderId,
        event.orderTotal,
      );
      emit(CashbackGenerated('🎉 Cashback coupon generated successfully!'));
    } catch (e) {
      emit(CouponError('Failed to generate cashback: $e'));
    }
  }

  Future<void> _onApplyCouponToCheckout(
      ApplyCouponToCheckout event,
      Emitter<CouponState> emit,
      ) async {
    emit(CouponLoading());

    try {
      final coupon = await _couponRepository.validateAndReserveCoupon(
        event.userId,
        event.couponCode,
      );

      if (coupon != null) {
        final discountAmount = (event.orderTotal * coupon.discountPercent / 100)
            .clamp(0.0, coupon.value); // Don't exceed coupon value
        final finalTotal = (event.orderTotal - discountAmount).clamp(0.0, double.infinity);

        emit(CouponAppliedToCheckout(
          coupon: coupon,
          originalTotal: event.orderTotal,
          discountAmount: discountAmount,
          finalTotal: finalTotal,
        ));
      } else {
        emit(CouponError('Invalid or expired coupon'));
      }
    } catch (e) {
      emit(CouponError(e.toString()));
    }
  }

  Future<void> _onConfirmCouponUsage(
      ConfirmCouponUsage event,
      Emitter<CouponState> emit,
      ) async {
    try {
      await _couponRepository.applyCouponToOrder(
        event.userId,
        event.couponId,
        event.orderId,
      );

      emit(CouponUsed('Coupon applied successfully! Discount applied to your order.'));
    } catch (e) {
      emit(CouponError('Failed to apply coupon: $e'));
    }
  }

  Future<void> _onCancelCouponApplication(
      CancelCouponApplication event,
      Emitter<CouponState> emit,
      ) async {
    try {
      await _couponRepository.releaseCouponReservation(
        event.userId,
        event.couponId,
      );

      emit(CouponApplicationCancelled('Coupon application cancelled'));
    } catch (e) {
      print('Error cancelling coupon application: $e');
      emit(CouponApplicationCancelled('Coupon application cancelled'));
    }
  }

  @override
  Future<void> close() {
    _couponsSubscription?.cancel();
    return super.close();
  }
}

