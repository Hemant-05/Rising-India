import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/banner/bloc/banner_bloc.dart';
import 'package:share_plus/share_plus.dart';

class AddBannerScreen extends StatefulWidget {
  const AddBannerScreen({super.key});

  @override
  State<AddBannerScreen> createState() => _AddBannerScreenState();
}

class _AddBannerScreenState extends State<AddBannerScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Add New Banner', style: simple_text_style(fontSize: 18)),
          ],
        ),
        backgroundColor: AppColour.white,
      ),
      body: BlocBuilder<BannerBloc, BannerState>(
        builder: (context, state) {
          if (state is BannerLoading) {
            return Center(child: CircularProgressIndicator(color: AppColour.primary,));
          } else if (state is ErrorBanner) {
            return Center(child: Text(state.error));
          } if(state is BannerAdded){
            BlocProvider.of<BannerBloc>(
              context,
            ).add(LoadAllBannerEvent());
            Navigator.pop(context);
          }
          return Column(
            children: [
              _buildImageSection(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_imageFile != null) {
                    context.read<BannerBloc>().add(AddBannerEvent(_imageFile!));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please select an image for Banner',
                          style: simple_text_style(color: AppColour.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: elevated_button_style(),
                child: Text(
                  'Add Banner',
                  style: simple_text_style(
                    color: AppColour.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: AppColour.primary),
            const SizedBox(width: 8),
            Text(
              'Banner Image',
              style: simple_text_style(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 300,
              height: 200,
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
              _imageFile != null ? 'Change Image' : 'Select Image',
              style: simple_text_style(),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade600,
            ),
          ),
        ),
      ],
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
}
