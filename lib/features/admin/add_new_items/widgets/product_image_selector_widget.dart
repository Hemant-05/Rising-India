import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/features/admin/add_new_items/bloc/Image_cubit/image_cubit.dart';
import 'package:raising_india/features/admin/services/image_services.dart';

class ProductImageSelector extends StatelessWidget {
  final ImageServices _imageServices = ImageServices();

  ProductImageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageSelectionCubit, ImageSelectionState >(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildImagePicker(
              context,
              imageFile: state.images[0],
              onTap: () => _showImageSourceDialog(context, 0),
            ),
            _buildImagePicker(
              context,
              imageFile: state.images[1],
              onTap: () => _showImageSourceDialog(context, 1),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePicker(BuildContext context, {File? imageFile, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(8)),
        child: imageFile != null
            ? CircleAvatar(
          radius: 8,
            child: Image.file(imageFile, fit: BoxFit.cover))
            : Icon(Icons.add_a_photo, size: 40),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, int imageSlot) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.photo),
            title: Text('Pick from gallery'),
            onTap: () async {
              final image = await _imageServices.pickFromGallery();
              if (image != null) {
                context.read<ImageSelectionCubit>().setImageAtIndex(imageSlot, image);
              }
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take a photo'),
            onTap: () async {
              final image = await _imageServices.pickFromCamera();
              if (image != null) {
                context.read<ImageSelectionCubit>().setImageAtIndex(imageSlot, image);
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
