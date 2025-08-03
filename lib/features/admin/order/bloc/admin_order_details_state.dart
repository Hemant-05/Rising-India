part of 'admin_order_details_cubit.dart';


class AdminOrderDetailsState {
  final OrderModel? order;
  final bool loading;
  final String? error;

  AdminOrderDetailsState({this.order, this.loading = false, this.error});

  AdminOrderDetailsState copyWith({OrderModel? order, bool? loading, String? error}) {
    return AdminOrderDetailsState(
      order: order ?? this.order,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}
