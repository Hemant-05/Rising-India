part of 'product_search_bloc.dart';

sealed class ProductSearchState {}

class ProductSearchInitial extends ProductSearchState {}

class ProductSearchLoading extends ProductSearchState {}

class ProductSearchLoaded extends ProductSearchState {
  final List<ProductModel> results;

  ProductSearchLoaded(this.results);
}

class ProductSearchError extends ProductSearchState {
  final String message;

  ProductSearchError(this.message);
}