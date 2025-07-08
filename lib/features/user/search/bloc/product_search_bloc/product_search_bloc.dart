import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raising_india/models/product_model.dart';

part 'product_search_event.dart';
part 'product_search_state.dart';

class ProductSearchBloc extends Bloc<ProductSearchEvent, ProductSearchState> {
  final FirebaseFirestore firestore;

  ProductSearchBloc({required this.firestore}) : super(ProductSearchInitial()) {
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onSearchProducts(

      SearchProducts event,
      Emitter<ProductSearchState> emit,
      ) async {
    try {
      emit(ProductSearchLoading());

      final queryText = event.query.trim().toLowerCase();
      final nextQuery = queryText.substring(0, queryText.length - 1) +
          String.fromCharCode(queryText.codeUnitAt(queryText.length - 1) + 1);

      final querySnapshot = await firestore
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: queryText)
          .where('name', isLessThan: nextQuery)
          .get();

      final products = querySnapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data(),FirebaseAuth.instance.currentUser!.uid);
      }).toList();

      emit(ProductSearchLoaded(products));
    } catch (e) {
      emit(ProductSearchError("Something went wrong: $e"));
    }
  }
}