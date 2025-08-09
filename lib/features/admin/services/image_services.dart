import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
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
        /*final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final Reference ref = FirebaseStorage.instance.ref().child('products/$fileName');

        final UploadTask uploadTask = ref.putFile(image);
        final TaskSnapshot snapshot = await uploadTask;

        await snapshot.ref.getDownloadURL();*/
        imageUrls.add('https://example.com/${image.path.split('/').last}');
      } else {
        imageUrls.add('');
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