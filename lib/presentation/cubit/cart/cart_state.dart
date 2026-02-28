import 'package:equatable/equatable.dart';

import '../../../domain/entities/cart_item.dart';

class CartState extends Equatable {
  const CartState({this.items = const []});

  final List<CartItem> items;

  int get count => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.subtotal);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}
