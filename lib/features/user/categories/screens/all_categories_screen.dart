import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/home/bloc/user_product_bloc/category_product_bloc.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        title: Text('All Categories', style: simple_text_style(fontSize: 22)),
        backgroundColor: AppColour.white,
      ),
      body: BlocBuilder<CategoryProductBloc, CategoryProductState>(
        builder: (context, state) {
          return state.isLoading
              ? Center(
                  child: CircularProgressIndicator(color: AppColour.primary),
                )
              : state.categories.isEmpty
              ? Center(child: Text('No Categories Found'))
              : Center(
                  child: Text(
                    'All Categories will be displayed here',
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                );
        },
      ),
    );
  }
}
