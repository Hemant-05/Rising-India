import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/models/product_model.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final FirebaseFirestore firestore;
  ProductsCubit(this.firestore) : super(ProductsState(products: []));

  StreamSubscription? _sub;

  void fetchProducts() {
    emit(state.copyWith(loading: true));
    _sub = firestore.collection('products').snapshots().listen(
          (snap) {
        final prods = snap.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
        emit(ProductsState(products: prods));
      },
      onError: (e) => emit(state.copyWith(loading: false, error: e.toString())),
    );
  }

  Future<void> updateProductAvailable(String pid, bool value) async {
    await firestore.collection('products').doc(pid).update({'isAvailable': value});
  }

  Future<void> deleteProduct(BuildContext context, String pid,List<String> url_list) async {
    try {
      for (String url in url_list) {
        await deleteImage(url);
      }
      await FirebaseFirestore.instance.collection('products').doc(pid).delete();
      if (context.mounted) {
        Navigator.pop(context); // Close Product Detail Screen
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColour.primary,
                content: Text("Product deleted successfully",style: simple_text_style(),))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: AppColour.primary,
              content: Text("Delete failed: $e",style: simple_text_style(),))
      );
    }
  }

  // ✅ Delete image
  Future<bool> deleteImage(String downloadUrl) async {
    try {
      final Reference ref = FirebaseStorage.instance.refFromURL(downloadUrl);
      await ref.delete();
      print('✅ Image deleted successfully');
      return true;
    } catch (e) {
      print('❌ Delete error: $e');
      return false;
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}