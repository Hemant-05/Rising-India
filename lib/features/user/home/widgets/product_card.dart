import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/product_details/bloc/product_funtction_bloc/product_fun_bloc.dart';
import 'package:raising_india/features/user/product_details/screens/product_details_screen.dart';
import 'package:raising_india/models/product_model.dart';

class product_card extends StatelessWidget {
  final ProductModel product;
  const product_card({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final unavailable = product.isOutOfStock || !product.isAvailable;
    return Card.outlined(
      // Material 3 outlined card
      color: AppColour.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.read<ProductFunBloc>().add(
            CheckIsInCart(productId: product.pid),
          );
          context.read<ProductFunBloc>().add(
            GetProductByID(productId: product.pid),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with aspect ratio and top badges
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.15, // consistent card top
                  child: Image.network(
                    product.photos_list[1],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.image_not_supported_rounded, size: 30)),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '⭐ ${product.rating}',
                      style: simple_text_style(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      '₹ ${product.price}',
                      style: simple_text_style(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: simple_text_style(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    style: simple_text_style(
                      fontSize: 13,
                      color: AppColour.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        unavailable
                            ? Icons.cancel_outlined
                            : Icons.check_circle_outline,
                        size: 16,
                        color: unavailable ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        unavailable ? 'Unavailable' : 'In stock',
                        style: simple_text_style(
                          fontSize: 10,
                          color: unavailable ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
class product_card extends StatelessWidget {
  final ProductModel product;

  const product_card({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColour.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
          onTap: () {
            context.read<ProductFunBloc>().add(
              CheckIsInCart(productId: product.pid),
            );
            context.read<ProductFunBloc>().add(
              GetProductByID(productId: product.pid),
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
                  child: Image.network(
                    product.photos_list[0],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.error_outline_outlined,size: 40,)),
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
                    (!product.isOutOfStock && product.isAvailable)? '₹ ${product.price}' : 'Out of Stock !!',
                    style: simple_text_style(color: (!product.isOutOfStock && product.isAvailable)? AppColour.black : AppColour.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
