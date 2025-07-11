part of 'user_product_bloc.dart';

@immutable
sealed class UserProductEvent {}

final class FetchProducts extends UserProductEvent {}

final class FetchBestSellingProducts extends UserProductEvent {}

final class FetchProductsByCategory extends UserProductEvent {
  final String category;
  FetchProductsByCategory(this.category);
}

