import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/add_new_items/bloc/Image_cubit/image_cubit.dart';
import 'package:raising_india/features/admin/add_new_items/bloc/product_bloc/product_bloc.dart';
import 'package:raising_india/features/admin/add_new_items/widgets/product_image_selector_widget.dart';
import 'package:raising_india/features/admin/category/bloc/category_bloc.dart';
import 'package:raising_india/models/product_model.dart';
import 'package:uuid/uuid.dart';

class AddNewItemScreen extends StatefulWidget {
  const AddNewItemScreen({super.key});

  @override
  State<AddNewItemScreen> createState() => _AddNewItemScreenState();
}

class _AddNewItemScreenState extends State<AddNewItemScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _stockQuantityController =
      TextEditingController();
  final TextEditingController _itemDescriptionController =
      TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _measurementController = TextEditingController();
  final TextEditingController _lowStockController = TextEditingController();
  final List<File?> photos_list = [];
  final List<String> photos_list_urls = [];
  bool isAvailable = true;

  @override
  void dispose() {
    super.dispose();
    _priceController.dispose();
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _measurementController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        title: Row(
          children: [
            Text('Add New Item', style: simple_text_style(fontSize: 20)),
            Spacer(),
            TextButton(
              onPressed: () {
                _priceController.clear();
                _itemNameController.clear();
                _itemDescriptionController.clear();
                _categoryController.clear();
                photos_list.clear();
                photos_list_urls.clear();
                _quantityController.clear();
                _measurementController.clear();
                context.read<ImageSelectionCubit>().clearImages();
                setState(() {});
              },
              child: Text(
                'RESET',
                style: simple_text_style(color: AppColour.primary),
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductAddLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProductAddError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ProductAdded) {
            _priceController.clear();
            _itemNameController.clear();
            _itemDescriptionController.clear();
            _categoryController.clear();
            _quantityController.clear();
            _measurementController.clear();
            context.read<ImageSelectionCubit>().clearImages();
            photos_list.clear();
            photos_list_urls.clear();
            return main_ui(context);
          }
          return main_ui(context);
        },
      ),
    );
  }

  Widget main_ui(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageSelector(),
            SizedBox(height: 12),
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter product name',
                hintStyle: simple_text_style(color: AppColour.lightGrey),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColour.primary, width: 2),
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColour.primary,
                          width: 2,
                        ),
                      ),
                      hintText: 'Price',
                      hintStyle: simple_text_style(color: AppColour.lightGrey),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                BlocConsumer<CategoryBloc, CategoryState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    return Expanded(
                      child: DropdownMenu(
                        width: double.infinity,
                        controller: _categoryController,
                        textStyle: TextStyle(
                          fontFamily: 'Sen',
                          color: AppColour.lightGrey,
                        ),
                        hintText: 'Category',
                        menuStyle: MenuStyle(
                          backgroundColor: MaterialStateProperty.all(
                            AppColour.white,
                          ),
                        ),
                        dropdownMenuEntries: state is CategoryLoaded
                            ? state.categories
                                  .map(
                                    (category) => DropdownMenuEntry(
                                      value: category.name,
                                      label: category.name,
                                    ),
                                  )
                                  .toList()
                            : [],
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Selling Quantity',
                      hintStyle: simple_text_style(color: AppColour.lightGrey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColour.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: DropdownMenu(
                    width: double.infinity,
                    controller: _measurementController,
                    textStyle: simple_text_style(color: AppColour.lightGrey),
                    hintText: 'Measurement',
                    menuStyle: MenuStyle(
                      backgroundColor: MaterialStateProperty.all(
                        AppColour.white,
                      ),
                    ),
                    dropdownMenuEntries: [
                      DropdownMenuEntry(value: 'KG', label: 'kg'),
                      DropdownMenuEntry(value: 'GM', label: 'gm'),
                      DropdownMenuEntry(value: 'LITER', label: 'liter'),
                      DropdownMenuEntry(value: 'ML', label: 'ml'),
                      DropdownMenuEntry(value: 'PCS', label: 'pcs'),
                      DropdownMenuEntry(value: 'Dar', label: 'darjan'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stockQuantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Stock Quantity',
                      hintStyle: simple_text_style(color: AppColour.lightGrey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColour.primary, width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _lowStockController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Low Quantity Alert',
                      hintStyle: simple_text_style(color: AppColour.lightGrey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColour.primary, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ratingController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Rating',
                      hintStyle: simple_text_style(color: AppColour.lightGrey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColour.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('In Stock', style: simple_text_style(fontSize: 16)),
                      Switch(
                        activeColor: AppColour.primary,
                        value: isAvailable,
                        onChanged: (value) {
                          isAvailable = value;
                          context.read<ProductBloc>().add(
                            ToggleAvailabilityEvent(value),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            TextField(
              controller: _itemDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter product description (100 words max)',
                hintStyle: simple_text_style(color: AppColour.lightGrey),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColour.primary, width: 2),
                ),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              style: elevated_button_style(),
              onPressed: () async {
                String pid = Uuid().v4();
                photos_list.addAll(
                  context.read<ImageSelectionCubit>().state.images,
                );
                photos_list_urls.addAll(
                  await context.read<ImageSelectionCubit>().getImageUrl(
                    photos_list,
                  ),
                );
                String uid = FirebaseAuth.instance.currentUser!.uid;
                double price = double.parse(_priceController.text.trim());
                String itemName = _itemNameController.text.trim();
                String itemDescription = _itemDescriptionController.text.trim();
                String category = _categoryController.text.trim();
                double sellQuantity = double.parse(_quantityController.text.trim());
                String measurement = _measurementController.text.trim();
                double rating = double.parse(_ratingController.text.trim());
                double stockQuantity = double.parse(_stockQuantityController.text.trim(),);
                double lowStockQuantity = double.parse(_lowStockController.text.trim());
                ProductModel newItem = ProductModel(
                  price: price,
                  name: itemName,
                  name_lower: itemName.toLowerCase(),
                  description: itemDescription,
                  category: category,
                  rating: rating,
                  quantity: sellQuantity,
                  measurement: measurement,
                  photos_list: photos_list_urls,
                  pid: pid,
                  uid: uid,
                  isAvailable: isAvailable,
                  stockQuantity: stockQuantity,
                  lowStockQuantity: lowStockQuantity,
                );
                BlocProvider.of<ProductBloc>(
                  context,
                ).add(AddProductEvent(uid, newItem));
              },
              child: Text(
                'Add Item',
                style: simple_text_style(color: AppColour.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
