part of 'product_bloc.dart';


@immutable
sealed class ProductState {}

final class ProductInitial extends ProductState {}

final class ProductLoading extends ProductState {}

final class ProductFetched extends ProductState {
  final List<ProductModel> products;
  ProductFetched(this.products);
}

final class ProductAvailabilityToggled extends ProductState {
  final bool isAvailable;
  ProductAvailabilityToggled(this.isAvailable);
}

final class ProductFetchError extends ProductState {
  final String message;
  ProductFetchError(this.message);
}

final class ProductAdded extends ProductState {
  final String message;
  ProductAdded(this.message);
}

final class ProductAddLoading extends ProductState {}

final class ProductUpdated extends ProductState {
  final String message;
  ProductUpdated(this.message);
}

final class ProductDeleted extends ProductState {
  final String message;
  ProductDeleted(this.message);
}

final class ProductAddError extends ProductState {
  final String message;
  ProductAddError(this.message);
}

final class ProductUpdateError extends ProductState {
  final String message;
  ProductUpdateError(this.message);
}

final class ProductDeleteError extends ProductState {
  final String message;
  ProductDeleteError(this.message);
}

final class ProductFetchByIdLoading extends ProductState {}

final class ProductFetchByIdLoaded extends ProductState {
  final ProductModel product;
  ProductFetchByIdLoaded(this.product);
}

final class ProductFetchByIdFailure extends ProductState {
  final String message;
  ProductFetchByIdFailure(this.message);
}

