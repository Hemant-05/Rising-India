part of 'category_bloc.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;

  CategoryLoaded(this.categories);
}

class CategoryActionLoading extends CategoryState {
  final List<CategoryModel> categories;

  CategoryActionLoading(this.categories);
}

class CategoryError extends CategoryState {
  final String message;
  final List<CategoryModel>? categories;

  CategoryError({
    required this.message,
    this.categories,
  });
}

class CategoryActionSuccess extends CategoryState {
  final List<CategoryModel> categories;
  final String message;

  CategoryActionSuccess({
    required this.categories,
    required this.message,
  });
}