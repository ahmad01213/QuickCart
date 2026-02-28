import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._local);

  final CartLocalDatasource _local;

  @override
  Future<List<CartItem>> getCartItems() => _local.getCartItems();

  @override
  Future<void> saveCartItems(List<CartItem> items) =>
      _local.saveCartItems(items);
}
