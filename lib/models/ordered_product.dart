import 'package:raising_india/models/product_model.dart';

class OrderedProduct {
  final ProductModel? product;
  final int qty;

  OrderedProduct({required this.product, required this.qty});
}