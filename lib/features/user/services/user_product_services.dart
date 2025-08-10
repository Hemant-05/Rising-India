import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raising_india/models/category_model.dart';
import 'package:raising_india/models/product_model.dart';

class UserProductServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> addProductToCart(String productId, int quantity) async {
    try {
      String uid = _auth.currentUser!.uid;
      _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(productId)
          .set({
            'productId': productId,
            'quantity': quantity,
          });
      return true;
    } catch (e) {
      throw Exception('Failed to add product to cart: $e');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final querySnapshot = await _firestore.collection('categories').get();
      return querySnapshot.docs.map((doc) => CategoryModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCartProducts() async {
    try {
      String uid = _auth.currentUser!.uid;
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .get();
      List<Map<String, dynamic>> cartProducts = [];
      for (var doc in querySnapshot.docs) {
        final productId = doc.data()['productId'];
        final model = await getProductById(productId);
        cartProducts.add({
          'productId': productId,
          'product': ProductModel.fromMap(model.toMap(), productId),
          'quantity': doc.data()['quantity'],
        });
      }
      return cartProducts;
    } catch (e) {
      throw Exception('Failed to fetch cart products: $e');
    }
  }

  Future<ProductModel> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data()!, doc.id);
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch product by ID: $e');
    }
  }

  Future<bool> removeProductFromCart(String productId) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(productId)
          .delete();
      return true;
    } catch (e) {
      throw Exception('Failed to remove product from cart: $e');
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> isInCart(
    String productId,
  ) async {
    try {
      String uid = _auth.currentUser!.uid;
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(productId)
          .get();
      return doc;
    } catch (e) {
      throw Exception('Failed to check if product is in cart: $e');
    }
  }

  Future<bool> clearCart() async {
    try {
      String uid = _auth.currentUser!.uid;
      final cartCollection = _firestore
          .collection('users')
          .doc(uid)
          .collection('cart');
      final querySnapshot = await cartCollection.get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  Future<int> getCartProductCount() async {
    try {
      String uid = _auth.currentUser!.uid;
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to fetch cart product count: $e');
    }
  }

  Future<List<Map<String, dynamic>>> updateCartProductQuantity(
    String productId,
    int quantity,
  ) async {
    try {
      String uid = _auth.currentUser!.uid;
      // updating the quantity of the product in the cart
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(productId)
          .update({'quantity': quantity});

      // fetching the updated cart products
      var querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .get();

      List<Map<String, dynamic>> updateCartProducts = [];
      for (var doc in querySnapshot.docs) {
        final productId = doc.data()['productId'];
        final model = await getProductById(productId);

        updateCartProducts.add({
          'productId': productId,
          'product': ProductModel.fromMap(model.toMap(), productId),
          'quantity': doc.data()['quantity'],
        });
      }
      return updateCartProducts;
    } catch (e) {
      throw Exception('Failed to update product quantity in cart: $e');
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();
      return querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      final querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<List<ProductModel>> getBestSellingProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .orderBy('rating', descending: true)
          .limit(4)
          .get();
      return querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch best selling products: $e');
    }
  }
}
