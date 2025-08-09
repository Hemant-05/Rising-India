class CategoryModel {
  final String id;
  final String name;
  final String image;
  final String value;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.value,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      value: data['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'value': value,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? image,
    String? value,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      value: value ?? this.value,
    );
  }
}
