part of 'category_product_bloc.dart';

@immutable
sealed class CategoryProductEvent {}

final class FetchProducts extends CategoryProductEvent {}

final class FetchCategories extends CategoryProductEvent {}

final class FetchBestSellingProducts extends CategoryProductEvent {}

final class FetchProductsByCategory extends CategoryProductEvent {
  final String category;
  FetchProductsByCategory(this.category);
}

