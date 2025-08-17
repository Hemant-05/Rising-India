part of 'category_bloc.dart';

abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {}

class AddCategory extends CategoryEvent {
  final String name;
  final String value;
  final File? imageFile;

  AddCategory({
    required this.name,
    required this.value,
    this.imageFile,
  });
}

class UpdateCategory extends CategoryEvent {
  final CategoryModel category;
  final File? newImageFile;

  UpdateCategory({
    required this.category,
    this.newImageFile,
  });
}

class DeleteCategory extends CategoryEvent {
  final String categoryId;
  final String url;
  DeleteCategory(this.categoryId,this.url);
}