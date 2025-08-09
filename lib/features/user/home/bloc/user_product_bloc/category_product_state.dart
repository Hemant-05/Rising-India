part of 'category_product_bloc.dart';

@immutable

class CategoryProductState {
  final List<ProductModel> allProducts;
  final List<ProductModel> bestSellingProducts;
  final List<ProductModel> productsByCategory;
  final List<Map<String,dynamic>> categories;
  final bool isLoading;
  final String? error;

  const CategoryProductState({
    required this.allProducts,
    required this.bestSellingProducts,
    required this.productsByCategory,
    required this.categories,
    required this.isLoading,
    this.error,
  });

  factory CategoryProductState.initial() => CategoryProductState(
    allProducts: [],
    bestSellingProducts: [],
    productsByCategory: [],
    categories: [],
    isLoading: false,
    error: null,
  );

  CategoryProductState copyWith({
    List<ProductModel>? allProducts,
    List<ProductModel>? productsByCategory,
    List<ProductModel>? bestSellingProducts,
    List<Map<String,dynamic>>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryProductState(
      allProducts: allProducts ?? this.allProducts,
      bestSellingProducts : bestSellingProducts?? this.bestSellingProducts,
      productsByCategory: productsByCategory ?? this.productsByCategory,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

