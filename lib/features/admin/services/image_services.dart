import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageServices {

  final ImagePicker _picker = ImagePicker();

  // also add logic to upload images to a server or cloud storage after some time
  Future<List<String>> uploadImages(List<File?> images) async {
    // Simulate image upload and return URLs
    List<String> imageUrls = [];
    await Future.delayed(Duration(seconds: 2));
    for (var image in images) {
      if (image != null) {
        imageUrls.add('https://example.com/${image.path.split('/').last}');
      } else {
        imageUrls.add('error while adding image');
      }
    }
    return imageUrls;
  }

  Future<File?> pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    return picked != null ? File(picked.path) : null;
  }

  Future<File?> pickFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    return picked != null ? File(picked.path) : null;
  }
}