import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raising_india/models/category_model.dart';
import 'package:raising_india/models/product_model.dart';
import 'package:uuid/uuid.dart';

class ProductServices {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final String _uid;
  ProductServices(this._uid);

  Future<List<ProductModel>> fetchProducts() async {
    if (_uid.isEmpty) {
      return [];
    }
    try {
      final QuerySnapshot snapshot = await _firebase
          .collection('products')
          .get();
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, _uid);
      }).toList();
    } on FirebaseException catch (e) {
      return Future.error('Error fetching products: ${e.message}');
    }
    return [];
  }

  Future<List<CategoryModel>> fetchCategories() async {
    if (_uid.isEmpty) {
      return [];
    }
    try {
      final QuerySnapshot snapshot = await _firebase
          .collection('categories')
          .get();
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } on FirebaseException catch (e) {
      return Future.error('Error fetching categories: ${e.message}');
    }
  }

  // Example method to fetch products by user ID
  Future<List<ProductModel>> fetchProductsByUserId(String userId) async {
    if (_uid.isEmpty || userId.isEmpty) {
      return [];
    }
    try {
      final QuerySnapshot snapshot = await _firebase
          .collection('products')
          .where('uid', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, _uid);
      }).toList();
    } on FirebaseException catch (e) {
      return Future.error('Error fetching products by user ID: ${e.message}');
    }
  }

  // Example method to fetch products by category
  Future<List<ProductModel>> fetchProductsByCategory(String category) async {
    if (_uid.isEmpty || category.isEmpty) {
      return [];
    }
    try {
      final QuerySnapshot snapshot = await _firebase
          .collection('products')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, _uid);
      }).toList();
    } on FirebaseException catch (e) {
      return Future.error('Error fetching products by category: ${e.message}');
    }
  }

  // Example method to fetch a single product by ID
  Future<ProductModel?> fetchProductById(String productId) async {
    if (_uid.isEmpty || productId.isEmpty) {
      return null;
    }
    try {
      final DocumentSnapshot doc = await _firebase.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, _uid);
      } else {
        return Future.error('400'); // Product not found
      }
    } on FirebaseException catch (e) {
      return Future.error('Error fetching product: ${e.message}');
    }
  }

  // Example method to add a new product
  Future<String> addProduct(ProductModel product) async {
    try {
      String pid = product.pid;
      await _firebase.collection('products').doc(pid).set(product.toMap());
      return 'Product added successfully';
    } on FirebaseException catch (e) {
     return 'Error adding product: ${e.message}';
    }
  }

  // Example method to update an existing product
  Future<String> updateProduct(ProductModel product) async {
    try {
      await _firebase.collection('products').doc(product.pid).update(product.toMap());
      return 'Product updated successfully';
    } on FirebaseException catch (e) {
      return Future.error('Error updating product: ${e.message}');
    }
  }

  // Example method to delete a product
  Future<String> deleteProduct(String productId) async {
    try {
      await _firebase.collection('products').doc(productId).delete();
      return 'Product deleted successfully';
    } on FirebaseException catch (e) {
      return Future.error('Error deleting product: ${e.message}');
    }
  }
}