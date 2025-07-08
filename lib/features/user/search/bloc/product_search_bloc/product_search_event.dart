part of 'product_search_bloc.dart';


sealed class ProductSearchEvent {}

class SearchProducts extends ProductSearchEvent {
  final String query;

  SearchProducts(this.query);
}