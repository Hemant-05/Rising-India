import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/category/bloc/category_bloc.dart';
import 'package:raising_india/models/category_model.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const AddEditCategoryScreen({super.key, this.category});

  bool get isEdit => category != null;

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _nameController.text = widget.category!.name;
      _valueController.text = widget.category!.value;
    }
  }

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
        Text(
          widget.isEdit ? 'Edit Category' : 'Add Category',style: simple_text_style(),),
            const Spacer(),
          ],
        ),
      ),
      body: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, state) {
          setState(() => _isLoading = false);
          if (state is CategoryActionSuccess) {
            Navigator.pop(context, true);
          } else if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message,style: simple_text_style(color: AppColour.white)),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                _buildImageSection(),
                const SizedBox(height: 24),

                // Form Section
                _buildFormSection(),
                const SizedBox(height: 32),

                // Submit Button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 2,
      color: AppColour.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.image_outlined, color: AppColour.primary),
                const SizedBox(width: 8),
                Text(
                  'Category Image',
                  style: simple_text_style(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: _buildImageWidget(),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(
                  _imageFile != null ||
                          (widget.isEdit && widget.category!.image.isNotEmpty)
                      ? 'Change Image'
                      : 'Select Image',
                  style: simple_text_style(),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _imageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else if (widget.isEdit && widget.category!.image.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.category!.image,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        ),
      );
    } else {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'Select Image',
          style: simple_text_style(color: AppColour.lightGrey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 2,
      color: AppColour.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_outlined, color: AppColour.primary),
                const SizedBox(width: 8),
                Text(
                  'Category Details',
                  style: simple_text_style(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category Name Field
            TextFormField(
              controller: _nameController,
              style: simple_text_style(),
              decoration: InputDecoration(
                hintText: 'e.g., Dairy Products',
                hintStyle: simple_text_style(),
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.orange.shade600),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter category name';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // Category Value Field
            TextFormField(
              controller: _valueController,
              style: simple_text_style(),
              decoration: InputDecoration(
                hintText: 'e.g., Dairy',
                hintStyle: simple_text_style(),
                prefixIcon: const Icon(Icons.tag_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.orange.shade600),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter category value';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Category value is used for filtering products and should be unique.',
                      style: TextStyle(
                        fontFamily: 'Sen',
                        color: Colors.blue.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: elevated_button_style(),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppColour.primary,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.isEdit ? 'Update Category' : 'Add Category',
                style: simple_text_style(
                  fontSize: 16,
                  color: AppColour.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final value = _valueController.text.trim();

      if (widget.isEdit) {
        context.read<CategoryBloc>().add(
          UpdateCategory(
            category: widget.category!.copyWith(name: name, value: value),
            newImageFile: _imageFile,
          ),
        );
      } else {
        context.read<CategoryBloc>().add(
          AddCategory(name: name, value: value, imageFile: _imageFile),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}
