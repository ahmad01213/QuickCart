import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.description,
    required super.category,
    required super.imageUrl,
    super.rating,
    super.ratingCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'];
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      imageUrl: json['image'] as String? ?? '',
      rating: rating != null ? (rating['rate'] as num).toDouble() : 0,
      ratingCount: rating != null ? rating['count'] as int : 0,
    );
  }
}
