part of 'product_bloc.dart';

@immutable
sealed class ProductEvent {}

final class FetchProductsEvent extends ProductEvent {
  final String uid;
  FetchProductsEvent(this.uid);
}

final class FetchProductByIdEvent extends ProductEvent {
  final String uid;
  final String productId;
  FetchProductByIdEvent(this.uid, this.productId);
}

final class AddProductEvent extends ProductEvent {
  final String uid;
  final ProductModel product;
  AddProductEvent(this.uid, this.product);
}

final class UpdateProductEvent extends ProductEvent {
  final String uid;
  final ProductModel product;
  UpdateProductEvent(this.uid, this.product);
}

final class DeleteProductEvent extends ProductEvent {
  final String uid;
  final String productId;
  DeleteProductEvent(this.uid, this.productId);
}

final class ToggleAvailabilityEvent extends ProductEvent {
  final bool isAvailable;
  ToggleAvailabilityEvent(this.isAvailable);
}
