class ProductModel {
  final String pid;
  final String uid;
  final String name;
  final String description;
  final double price;
  final double rating; // Default rating if not provided
  final bool isAvailable; // Default availability status
  final double quantity;
  final String name_lower;
  final String measurement;
  final String category;
  final List<String> photos_list;

  ProductModel({
    required this.uid,
    required this.photos_list,
    required this.isAvailable, // Default value for availability
    required this.pid,
    required this.name,
    required this.name_lower,
    required this.rating,
    required this.category,
    required this.description,
    required this.price,
    required this.quantity,
    required this.measurement,
  });
  // Factory constructor to create a ProductModel from a map
  factory ProductModel.fromMap(Map<String, dynamic> map,String uid) {
    return ProductModel(
      pid: map['pid'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      isAvailable: map['isAvailable'],
      name_lower: map['name_lower'],
      rating: (double.parse(map['rating'].toString())), // Default rating if not provided
      price: (double.parse(map['price'].toString())),
      quantity: (double.parse(map['quantity'].toString())),
      measurement: map['measurement'] ?? '',
      photos_list: List<String>.from(map['photos_list'] ?? []),
      uid: uid,
    );
  }
  // Method to convert ProductModel to a map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'pid': pid,
      'name': name,
      'name_lower' : name_lower,
      'category': category,
      'description': description,
      'isAvailable': isAvailable,
      'price': price,
      'rating': rating,
      'quantity': quantity,
      'measurement': measurement,
      'photos_list': photos_list,
    };
  }
}