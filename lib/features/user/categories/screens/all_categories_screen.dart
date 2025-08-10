import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/categories/widgets/category_widget.dart';
import 'package:raising_india/features/user/home/bloc/user_product_bloc/category_product_bloc.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('All Categories', style: simple_text_style(fontSize: 20)),
          ],
        ),
      ),
      body: BlocBuilder<CategoryProductBloc, CategoryProductState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: state.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColour.primary),
                  )
                : state.categories.isEmpty
                ? Center(child: Text('No Categories Found'))
                : GridView.builder(
                    itemCount: state.categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85
                    ),
                    itemBuilder: (context, index) =>
                        category_widget(context, state.categories[index]),
                  ),
          );
        },
      ),
    );
  }
}
