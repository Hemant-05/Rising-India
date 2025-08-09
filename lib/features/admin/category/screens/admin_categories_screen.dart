import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/category/bloc/category_bloc.dart';
import 'package:raising_india/features/admin/category/screens/add_edit_category_screen.dart';
import 'package:raising_india/features/admin/category/screens/category_products_screen.dart';
import 'package:raising_india/models/category_model.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

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
            Text('Categories', style: simple_text_style(fontSize: 20)),
          ],
        ),
        actions: [
          InkWell(
            onTap: () => _navigateToAddCategory(context),
            child: Text(
              'Add Category',
              style: simple_text_style(
                fontWeight: FontWeight.bold,
                color: AppColour.primary,
              ),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryActionSuccess) {
            context.read<CategoryBloc>().add(LoadCategories());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: simple_text_style(color: AppColour.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: simple_text_style(color: AppColour.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: _buildCategoriesGrid(context, state),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, CategoryState state) {
    if (state is CategoryLoading) {
      return Center(child: CircularProgressIndicator(color: AppColour.primary));
    }

    List<CategoryModel> categories = [];
    if (state is CategoryLoaded) {
      categories = state.categories;
    } else if (state is CategoryActionLoading) {
      categories = state.categories;
    } else if (state is CategoryError && state.categories != null) {
      categories = state.categories!;
    }

    if (categories.isEmpty) {
      return _buildEmptyState(context);
    }

    return Stack(
      children: [
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.88,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(context, category);
          },
        ),

        // Loading overlay
        if (state is CategoryActionLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: CircularProgressIndicator(color: AppColour.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryModel category) {
    return Card(
      elevation: 2,
      color: AppColour.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToCategoryProducts(context, category),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              height: 120,
              width: double.infinity,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                color: AppColour.lightGrey,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: category.image.isNotEmpty
                    ? Image.network(
                        category.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.category_outlined,
                          size: 50,
                          color: AppColour.primary,
                        ),
                      )
                    : Icon(
                        Icons.category_outlined,
                        size: 50,
                        color: AppColour.primary,
                      ),
              ),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: simple_text_style(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Value: ${category.value}',
                      style: simple_text_style(
                        fontSize: 12,
                        color: AppColour.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: AppColour.lightGrey),
          const SizedBox(height: 16),
          Text(
            'No categories found',
            style: simple_text_style(
              fontSize: 18,
              color: AppColour.lightGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first category to get started',
            style: simple_text_style(color: AppColour.lightGrey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToAddCategory(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Add Category',
              style: simple_text_style(
                color: AppColour.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddCategory(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<CategoryBloc>(context),
          child: const AddEditCategoryScreen(),
        ),
      ),
    );

  }

  void _navigateToCategoryProducts(
    BuildContext context,
    CategoryModel category,
  ) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsScreen(category: category),
      ),
    );
  }
}
