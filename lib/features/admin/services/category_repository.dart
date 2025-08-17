import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:raising_india/models/category_model.dart';

abstract class CategoryRepository {
  Stream<List<CategoryModel>> getCategories();
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId,String url);
  Future<String> uploadCategoryImage(File imageFile,String categoryName);
}

class CategoryRepositoryImpl implements CategoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CategoryRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection('categories')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();
    })
        .handleError((error) {
      throw Exception('Failed to load categories: $error');
    });
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    try {
      await _firestore.collection('categories').add(category.toMap());
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _firestore
          .collection('categories')
          .doc(category.id)
          .update(category.copyWith().toMap());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId,String url) async {
    try {
      await deleteImage(url);
      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // ✅ Delete image
  Future<bool> deleteImage(String downloadUrl) async {
    try {
      final Reference ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> uploadCategoryImage(File imageFile, String categoryName) async {
    try {
      // ✅ Check authentication
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // ✅ Create unique filename
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // ✅ Create reference with proper path
      final Reference ref = _storage.ref().child('category_images/$categoryName-$fileName');

      // ✅ Set metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': user.uid,
          'categoryName': categoryName,
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
}
