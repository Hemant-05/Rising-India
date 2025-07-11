part of 'user_product_bloc.dart';

@immutable

class UserProductState {
  final List<ProductModel> allProducts;
  final List<ProductModel> bestSellingProducts;
  final List<ProductModel> productsByCategory;
  final bool isLoading;
  final String? error;

  const UserProductState({
    required this.allProducts,
    required this.bestSellingProducts,
    required this.productsByCategory,
    required this.isLoading,
    this.error,
  });

  factory UserProductState.initial() => UserProductState(
    allProducts: [],
    bestSellingProducts: [],
    productsByCategory: [],
    isLoading: false,
    error: null,
  );

  UserProductState copyWith({
    List<ProductModel>? allProducts,
    List<ProductModel>? productsByCategory,
    List<ProductModel>? bestSellingProducts,
    bool? isLoading,
    String? error,
  }) {
    return UserProductState(
      allProducts: allProducts ?? this.allProducts,
      bestSellingProducts : bestSellingProducts?? this.bestSellingProducts,
      productsByCategory: productsByCategory ?? this.productsByCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

