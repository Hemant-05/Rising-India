part of 'product_fun_bloc.dart';

@immutable
class ProductFunState {
  final int quantity;
  final bool isAddingToCart;
  final bool isAddedToCart;
  final bool isRemovingToCart;
  final bool isRemovedToCart;
  final bool isLoadingCartProduct;
  final List<Map<String, dynamic>> getCartProduct;
  final bool isUpdatingProductQuantity;
  final bool isUpdatedProductQuantity;
  final bool isCartClearing;
  final bool isCartCleared;
  final bool isCheckingIsInCart;
  final bool isInCart;
  final bool isGettingCartProductCount;
  final int cartProductCount;
  final String? error;

  const ProductFunState({
    required this.quantity,
    required this.isAddingToCart,
    required this.isAddedToCart,
    required this.isRemovingToCart,
    required this.isRemovedToCart,
    required this.isLoadingCartProduct,
    required this.getCartProduct,
    required this.isUpdatingProductQuantity,
    required this.isUpdatedProductQuantity,
    required this.isCartClearing,
    required this.isCartCleared,
    required this.isCheckingIsInCart,
    required this.isInCart,
    required this.isGettingCartProductCount,
    required this.cartProductCount,
    this.error,
  });

  factory ProductFunState.initial() {
    return ProductFunState(
      quantity: 1,
      isAddingToCart: false,
      isAddedToCart: false,
      isRemovingToCart: false,
      isRemovedToCart: false,
      isLoadingCartProduct: false,
      getCartProduct: const [],
      isUpdatingProductQuantity: false,
      isUpdatedProductQuantity: false,
      isCartClearing: false,
      isCartCleared: false,
      isCheckingIsInCart: false,
      cartProductCount: 0,
      isGettingCartProductCount: false,
      isInCart: false,
      error: null,
    );
  }

  ProductFunState copyWith({
    int? quantity,
    bool? isAddingToCart,
    bool? isAddedToCart,
    bool? isRemovingToCart,
    bool? isRemovedToCart,
    bool? isLoadingCartProduct,
    List<Map<String, dynamic>>? getCartProduct,
    bool? isUpdatingProductQuantity,
    bool? isUpdatedProductQuantity,
    bool? isCartClearing,
    bool? isCartCleared,
    bool? isCheckingIsInCart,
    bool? isInCart,
    bool? isGettingCartProductCount,
    int? cartProductCount,
    String? error,
  }) {
    return ProductFunState(
      quantity: quantity ?? this.quantity,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      isAddedToCart: isAddedToCart ?? this.isAddedToCart,
      error: error ?? this.error,
      isRemovingToCart: isRemovingToCart ?? this.isRemovingToCart,
      isRemovedToCart: isRemovedToCart ?? this.isRemovedToCart,
      isLoadingCartProduct: isLoadingCartProduct ?? this.isLoadingCartProduct,
      getCartProduct: getCartProduct ?? this.getCartProduct,
      isUpdatingProductQuantity:
          isUpdatingProductQuantity ?? this.isUpdatingProductQuantity,
      isUpdatedProductQuantity:
          isUpdatedProductQuantity ?? this.isUpdatedProductQuantity,
      isCartClearing: isCartClearing ?? this.isCartClearing,
      isCartCleared: isCartCleared ?? this.isCartCleared,
      isCheckingIsInCart: isCheckingIsInCart ?? this.isCheckingIsInCart,
      isInCart: isInCart ?? this.isInCart,
      isGettingCartProductCount:
          isGettingCartProductCount ?? this.isGettingCartProductCount,
      cartProductCount: cartProductCount ?? this.cartProductCount,
    );
  }
}
