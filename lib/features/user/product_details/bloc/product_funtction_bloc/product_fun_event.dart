part of 'product_fun_bloc.dart';

abstract class ProductFunEvent {}

class IncreaseQuantity extends ProductFunEvent {}

class DecreaseQuantity extends ProductFunEvent {}

class AddToCartPressed extends ProductFunEvent {
  String productId;
  AddToCartPressed({required this.productId});
}

class RemoveFromCartPressed extends ProductFunEvent {
  String productId;
  RemoveFromCartPressed({required this.productId});
}

class CheckIsInCart extends ProductFunEvent {
  String productId;
  CheckIsInCart({required this.productId});
}

class UpdateProductQuantityPressed extends ProductFunEvent {
  String productId;
  int quantity;
  UpdateProductQuantityPressed({required this.productId, required this.quantity});
}

class ClearCartPressed extends ProductFunEvent {}
class GetCartProductCount extends ProductFunEvent {}
class GetCartProductPressed extends ProductFunEvent {}