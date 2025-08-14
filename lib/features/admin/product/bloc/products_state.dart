part of 'products_cubit.dart';

class ProductsState {
  final List<ProductModel> products;
  final bool loading;
  final String? error;
  ProductsState({required this.products, this.loading = false, this.error});
  ProductsState copyWith({
    List<ProductModel>? products,
    bool? loading,
    String? error,
  }) => ProductsState(
    products: products ?? this.products,
    loading: loading ?? this.loading,
    error: error ?? this.error,
  );
}
