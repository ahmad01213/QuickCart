import 'product.dart';

class CartItem {
  const CartItem({required this.product, this.quantity = 1});

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromMap(Map<String, dynamic>.from(map['product'] as Map)),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
