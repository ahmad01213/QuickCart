import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remote);

  final ProductRemoteDatasource _remote;

  @override
  Future<List<Product>> getProducts() async {
    return _remote.fetchProducts();
  }

  @override
  Future<Product?> getProductById(int id) async {
    return _remote.fetchProductById(id);
  }
}
