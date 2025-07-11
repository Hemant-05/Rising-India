import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/product_details/bloc/product_funtction_bloc/product_fun_bloc.dart';
import 'package:raising_india/features/user/product_details/screens/product_details_screen.dart';
import 'package:raising_india/models/product_model.dart';

class product_card extends StatelessWidget {
  final ProductModel product;

  const product_card({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: product.isAvailable? AppColour.white : AppColour.lightGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
          onTap: () {
            context.read<ProductFunBloc>().add(
              CheckIsInCart(productId: product.pid),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(product: product),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Hero(
                    tag: '${product.pid}',
                    child: Image.network(
                      product.photos_list[1],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: simple_text_style(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    product.category,
                    style: simple_text_style(
                      fontSize: 14,
                      color: AppColour.grey,
                    ),
                  ),
                  Text(
                    product.isAvailable? '₹ ${product.price}' : 'Out of Stock',
                    style: simple_text_style(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}