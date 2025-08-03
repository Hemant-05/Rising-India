import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/all_product_list/bloc/products_cubit.dart';
import 'package:raising_india/features/admin/all_product_list/screens/admin_product_details_screen.dart';

class AllProductListA extends StatelessWidget {
  const AllProductListA({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.loading) return Center(child: CircularProgressIndicator());
        if (state.error != null)
          return Center(child: Text("Error: ${state.error}"));
        final products = state.products;
        return Scaffold(
          backgroundColor: AppColour.white,
          appBar: AppBar(
            backgroundColor: AppColour.white,
            title: Text("All Products", style: simple_text_style(fontSize: 20)),
          ),
          body: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, i) {
              final prod = products[i];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColour.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColour.black.withOpacity(0.2),
                      blurRadius: 3,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: prod.photos_list.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            prod.photos_list.first,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  alignment: Alignment.center,
                                  height: 48,
                                  width: 48,
                                  child: Icon(Icons.error_outline_rounded),
                                ),
                          ),
                        )
                      : Icon(Icons.image, size: 45),
                  title: Text(
                    prod.name,
                    style: simple_text_style(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "₹${prod.price} • ${prod.measurement}",
                    style: simple_text_style(),
                  ),
                  trailing: Switch(
                    value: prod.isAvailable,
                    onChanged: (v) => context
                        .read<ProductsCubit>()
                        .updateProductAvailable(prod.pid, v),
                    activeColor: AppColour.primary,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminProductDetailScreen(product: prod),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
