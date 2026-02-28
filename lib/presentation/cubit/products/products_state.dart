import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';

enum ProductsStatus { initial, loading, loaded, error }

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.errorMessage,
    this.selectedCategory = 'all',
    this.searchQuery = '',
  });

  final ProductsStatus status;
  final List<Product> products;
  final String? errorMessage;
  /// 'all' = show all; otherwise filter by this category name.
  final String? selectedCategory;
  final String searchQuery;

  List<String> get categories {
    final set = <String>{};
    for (final p in products) {
      if (p.category.isNotEmpty) set.add(p.category);
    }
    final list = set.toList()..sort();
    return list;
  }

  List<Product> get filteredProducts {
    var list = products;
    if (selectedCategory != null &&
        selectedCategory!.isNotEmpty &&
        selectedCategory != 'all') {
      list = list.where((p) => p.category == selectedCategory).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              (p.category.toLowerCase().contains(q)))
          .toList();
    }
    return list;
  }

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    String? errorMessage,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [status, products, errorMessage, selectedCategory, searchQuery];
}
