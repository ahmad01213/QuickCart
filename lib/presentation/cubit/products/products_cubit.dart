import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/product_repository.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._productRepository) : super(const ProductsState());

  final ProductRepository _productRepository;

  Future<void> loadProducts() async {
    emit(state.copyWith(status: ProductsStatus.loading, errorMessage: null));
    try {
      final products = await _productRepository.getProducts();
      emit(state.copyWith(
        status: ProductsStatus.loaded,
        products: products,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: 'فشل تحميل المنتجات. تحقق من الاتصال وحاول مرة أخرى.',
      ));
    }
  }

  void selectCategory(String? category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
