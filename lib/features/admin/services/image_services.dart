import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageServices {

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<String>> uploadImages(List<File?> images,String productName) async {
    List<String> imageUrls = [];
    for (var image in images) {
      if (image != null) {
        String? url = await _uploadProductImage(image, productName);
        imageUrls.add(url!);
      } else {
        imageUrls.add('');
      }
    }
    return imageUrls;
  }

  Future<String> uploadBannerImage(File image) async {
    try{
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final Reference ref = _storage.ref().child('banner_images/$fileName');

      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': user.uid,
          'uploadTime': DateTime.now().toIso8601String(),
        },
      );

      final UploadTask uploadTask = ref.putFile(image, metadata);

      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    }catch(e){
      return 'Error uploading image: $e';
    }
  }

  Future<String?> _uploadProductImage(File imageFile, String productName) async {
    try {
      // ✅ Check authentication
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // ✅ Create unique filename
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // ✅ Create reference with proper path
      final Reference ref = _storage.ref().child('product_images/$productName-$fileName');

      // ✅ Set metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': user.uid,
          'productId': productName,
          'uploadTime': DateTime.now().toIso8601String(),
        },
      );

      // ✅ Upload with metadata
      final UploadTask uploadTask = ref.putFile(imageFile, metadata);

      // ✅ Wait for completion
      final TaskSnapshot snapshot = await uploadTask;

      // ✅ Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;

    } on FirebaseException catch (e) {
      print('❌ Firebase Storage Error: ${e.code} - ${e.message}');

      // ✅ Handle specific errors
      switch (e.code) {
        case 'storage/unauthorized':
          throw Exception('Permission denied. Please check your authentication.');
        case 'storage/canceled':
          throw Exception('Upload was canceled.');
        case 'storage/unknown':
          throw Exception('An unknown error occurred during upload.');
        default:
          throw Exception('Upload failed: ${e.message}');
      }
    } catch (e) {
      print('❌ Upload Error: $e');
      throw Exception('Failed to upload image: $e');
    }
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