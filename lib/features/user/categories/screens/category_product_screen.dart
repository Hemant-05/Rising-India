import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/home/bloc/user_product_bloc/user_product_bloc.dart';
import 'package:raising_india/features/user/home/widgets/product_grid.dart';

class CategoryProductScreen extends StatefulWidget {
  const CategoryProductScreen({super.key, required this.category});

  final String category;

  @override
  State<CategoryProductScreen> createState() => _CategoryProductScreenState();
}

class _CategoryProductScreenState extends State<CategoryProductScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<UserProductBloc>(
      context,
    ).add(FetchProductsByCategory(widget.category));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 10),
            Text(widget.category, style: simple_text_style(fontSize: 20,),),
            const Spacer(),
          ],
        ),
      ),
      body: BlocBuilder<UserProductBloc, UserProductState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: state.isLoading
                ? Center(child: CircularProgressIndicator()) :
                state.productsByCategory.isNotEmpty ?
                ProductGrid(products: state.productsByCategory) :
                state.productsByCategory.isEmpty
                      ? Center(child: Text('No Product in this Category !!!'))
                : state.error != null
                ? Center(child: Text(state.error!))
                : Center(child: Text('No products found')),
          );
        },
      ),
    );
  }
}
