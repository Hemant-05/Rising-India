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
  final TextEditingController _itemDescriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _measurementController = TextEditingController();
  final List<File?> photos_list = [];
  final List<String> photos_list_urls = [];
  bool isAvailable = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: [
            Text('Add New Item', style: simple_text_style()),
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
            SizedBox(height: 6),
            Row(
              children: [
                Text('Available', style: simple_text_style(fontSize: 16)),
                Spacer(),
                Switch(
                  value: isAvailable,
                  onChanged: (value) {
                    isAvailable = value;
                    context.read<ProductBloc>().add(ToggleAvailabilityEvent(value));
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter item name',
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
                      label: Text(
                        'Price',
                        style: simple_text_style(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                DropdownMenu(
                  controller: _categoryController,
                  textStyle: simple_text_style(),
                  hintText: 'Category',
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                      value: 'Vegetable',
                      label: 'Vegetable',
                    ),
                    DropdownMenuEntry(value: 'Fruit', label: 'Fruit'),
                    DropdownMenuEntry(value: 'Dairy', label: 'Dairy'),
                  ],
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
                      hintText: 'Enter quantity',
                    ),
                  ),
                ),
                SizedBox(width: 12),
                DropdownMenu(
                  controller: _measurementController,
                  textStyle: simple_text_style(),
                  hintText: 'Measurement',
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: 'KG', label: 'kg'),
                    DropdownMenuEntry(value: 'GM', label: 'gm'),
                    DropdownMenuEntry(value: 'LITER', label: 'liter'),
                    DropdownMenuEntry(value: 'ML', label: 'ml'),
                    DropdownMenuEntry(value: 'PCS', label: 'pcs'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            TextField(
              controller: _itemDescriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter item description (100 words max)',
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              style: elevated_button_style(),
              onPressed: () async {
                String pid = Uuid().v4();
                photos_list.addAll(context.read<ImageSelectionCubit>().state.images);
                photos_list_urls.addAll(await context.read<ImageSelectionCubit>().getImageUrl(photos_list));
                String uid = FirebaseAuth.instance.currentUser!.uid;
                String price = _priceController.text.trim();
                String itemName = _itemNameController.text.trim();
                String itemDescription = _itemDescriptionController.text.trim();
                String category = _categoryController.text.trim();
                String quantity = _quantityController.text.trim();
                String measurement = _measurementController.text.trim();
                ProductModel newItem = ProductModel(
                  price: double.parse(price),
                  name: itemName,
                  description: itemDescription,
                  category: category,
                  rating: 0.0,
                  quantity: double.parse(quantity),
                  measurement: measurement,
                  photos_list: photos_list_urls,
                  pid: pid,
                  uid: uid,
                  isAvailable: isAvailable,
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
