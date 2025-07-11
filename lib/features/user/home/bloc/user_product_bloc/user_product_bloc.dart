import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:raising_india/features/user/services/user_product_services.dart';
import 'package:raising_india/models/product_model.dart';
part 'user_product_event.dart';
part 'user_product_state.dart';

class UserProductBloc extends Bloc<UserProductEvent, UserProductState> {
  final UserProductServices services;
  UserProductBloc({required this.services}) : super(UserProductState.initial()) {
    on<UserProductEvent>((event, emit) {});
    on<FetchProducts>(_onFetchProducts);
    on<FetchBestSellingProducts>(_onFetchBestSellingProducts);
    on<FetchProductsByCategory>(_onFetchProductsByCategory);
  }

  FutureOr<void> _onFetchProducts(
    FetchProducts event,
    Emitter<UserProductState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final products = await services.getProducts();
      emit(state.copyWith(isLoading: false, allProducts: products));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  FutureOr<void> _onFetchBestSellingProducts(
    FetchBestSellingProducts event,
    Emitter<UserProductState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final bestSellingProducts = await services.getBestSellingProducts();
      emit(state.copyWith(
        isLoading: false,
        bestSellingProducts: bestSellingProducts,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  FutureOr<void> _onFetchProductsByCategory(
    FetchProductsByCategory event,
    Emitter<UserProductState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final products = await services.getProductsByCategory(event.category);
      emit(state.copyWith(
        isLoading: false,
        productsByCategory: products,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
