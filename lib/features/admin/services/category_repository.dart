import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:raising_india/models/category_model.dart';

abstract class CategoryRepository {
  Stream<List<CategoryModel>> getCategories();
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
  Future<String> uploadCategoryImage(File imageFile);
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
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  @override
  Future<String> uploadCategoryImage(File imageFile) async {
    try {
      /*final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference ref = _storage.ref().child('categories/$fileName');

      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();*/
      return '';
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
