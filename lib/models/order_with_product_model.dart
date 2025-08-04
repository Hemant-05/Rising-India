import 'package:raising_india/models/order_model.dart';
import 'package:raising_india/models/ordered_product.dart';

class OrderWithProducts {
  final OrderModel order;
  final List<OrderedProduct> products;

  OrderWithProducts({
    required this.order,
    required this.products,
  });
}