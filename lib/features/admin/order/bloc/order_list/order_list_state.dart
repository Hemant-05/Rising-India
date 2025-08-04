part of 'order_list_bloc.dart';

class OrderListState {
  final List<OrderWithProducts> orders;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;

  OrderListState({
    required this.orders,
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.hasMore = true,
    this.lastDocument,
  });

  OrderListState copyWith({
    List<OrderWithProducts>? orders,
    bool? loading,
    bool? loadingMore,
    String? error,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
  }) => OrderListState(
    orders: orders ?? this.orders,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: error ?? this.error,
    hasMore: hasMore ?? this.hasMore,
    lastDocument: lastDocument ?? this.lastDocument,
  );
}