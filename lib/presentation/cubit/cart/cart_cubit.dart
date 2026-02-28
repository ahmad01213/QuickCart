import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._repository) : super(const CartState());

  final CartRepository _repository;

  Future<void> loadCart() async {
    final items = await _repository.getCartItems();
    emit(CartState(items: items));
  }

  Future<void> add(Product product) async {
    final list = List<CartItem>.from(state.items);
    final index = list.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      list[index] = CartItem(
        product: list[index].product,
        quantity: list[index].quantity + 1,
      );
    } else {
      list.add(CartItem(product: product, quantity: 1));
    }
    emit(CartState(items: list));
    await _repository.saveCartItems(list);
  }

  Future<void> remove(Product product) async {
    final list =
        state.items.where((e) => e.product.id != product.id).toList();
    emit(CartState(items: list));
    await _repository.saveCartItems(list);
  }

  Future<void> setQuantity(Product product, int quantity) async {
    if (quantity < 1) {
      await remove(product);
      return;
    }
    final list = List<CartItem>.from(state.items);
    final index = list.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      list[index] = CartItem(product: list[index].product, quantity: quantity);
      emit(CartState(items: list));
      await _repository.saveCartItems(list);
    }
  }

  bool contains(Product product) {
    return state.items.any((e) => e.product.id == product.id);
  }
}
