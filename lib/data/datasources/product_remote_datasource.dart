import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDatasource {
  Future<List<ProductModel>> fetchProducts();
  Future<ProductModel?> fetchProductById(int id);
}

class ProductRemoteDatasourceImpl implements ProductRemoteDatasource {
  ProductRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final response = await _dio.get<List<dynamic>>(ApiConstants.productsPath);
    final list = response.data;
    if (list == null) return [];
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductModel?> fetchProductById(int id) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('${ApiConstants.productsPath}/$id');
      final data = response.data;
      if (data == null) return null;
      return ProductModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
