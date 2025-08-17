import 'dart:io';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:raising_india/features/admin/services/category_repository.dart';
import 'package:raising_india/models/category_model.dart';
import 'package:uuid/uuid.dart';
part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repository;
  StreamSubscription<List<CategoryModel>>? _categoriesSubscription;

  CategoryBloc({required CategoryRepository repository})
      : _repository = repository,
        super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
      LoadCategories event,
      Emitter<CategoryState> emit,
      ) async {
    emit(CategoryLoading());

    try {
      // Cancel previous subscription
      await _categoriesSubscription?.cancel();

      // ✅ Use emit.forEach for proper stream handling
      await emit.forEach<List<CategoryModel>>(
        _repository.getCategories(),
        onData: (categories) => CategoryLoaded(categories),
        onError: (error, stackTrace) {
          print('Error loading categories: $error');
          return CategoryError(message: 'Failed to load categories: $error');
        },
      );
    } catch (e) {
      print('Catch block error: $e');
      if (!emit.isDone) {
        emit(CategoryError(message: 'Failed to load categories: $e'));
      }
    }
  }

  Future<void> _onAddCategory(
      AddCategory event,
      Emitter<CategoryState> emit,
      ) async {
    final currentState = state;
    if (currentState is CategoryLoaded) {
      emit(CategoryActionLoading(currentState.categories));
    }

    try {
      String imageUrl = '';

      if (event.imageFile != null) {
        imageUrl = await _repository.uploadCategoryImage(event.imageFile!,event.name);
      }

      final category = CategoryModel(
        id: Uuid().v1(),
        name: event.name,
        image: imageUrl,
        value: event.value,
      );

      await _repository.addCategory(category);

      if (!emit.isDone) {
        emit(CategoryActionSuccess(
          categories: currentState is CategoryLoaded ? currentState.categories : [],
          message: 'Category added successfully',
        ));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(CategoryError(
          message: 'Failed to add category: $e',
          categories: currentState is CategoryLoaded ? currentState.categories : null,
        ));
      }
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event,
      Emitter<CategoryState> emit,
      ) async {
    final currentState = state;
    if (currentState is CategoryLoaded) {
      emit(CategoryActionLoading(currentState.categories));
    }

    try {
      String imageUrl = event.category.image;

      if (event.newImageFile != null) {
        imageUrl = await _repository.uploadCategoryImage(event.newImageFile!,event.category.name);
      }

      final updatedCategory = event.category.copyWith(
        image: imageUrl,
      );

      await _repository.updateCategory(updatedCategory);

      if (!emit.isDone) {
        emit(CategoryActionSuccess(
          categories: currentState is CategoryLoaded ? currentState.categories : [],
          message: 'Category updated successfully',
        ));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(CategoryError(
          message: 'Failed to update category: $e',
          categories: currentState is CategoryLoaded ? currentState.categories : null,
        ));
      }
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event,
      Emitter<CategoryState> emit,
      ) async {
    final currentState = state;
    if (currentState is CategoryLoaded) {
      emit(CategoryActionLoading(currentState.categories));
    }

    try {
      await _repository.deleteCategory(event.categoryId, event.url);

      if (!emit.isDone) {
        emit(CategoryActionSuccess(
          categories: currentState is CategoryLoaded ? currentState.categories : [],
          message: 'Category deleted successfully',
        ));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(CategoryError(
          message: 'Failed to delete category: $e',
          categories: currentState is CategoryLoaded ? currentState.categories : null,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    return super.close();
  }
}
