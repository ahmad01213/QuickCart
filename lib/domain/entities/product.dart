class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double rating;
  final int ratingCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.rating = 0,
    this.ratingCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': imageUrl,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] as num).toInt(),
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      description: map['description'] as String,
      category: map['category'] as String,
      imageUrl: map['image'] as String,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (map['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }
}
