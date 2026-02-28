import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../domain/entities/cart_item.dart';

abstract class CartLocalDatasource {
  Future<List<CartItem>> getCartItems();
  Future<void> saveCartItems(List<CartItem> items);
}

class CartLocalDatasourceImpl implements CartLocalDatasource {
  CartLocalDatasourceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<List<CartItem>> getCartItems() async {
    final json = _prefs.getString(StorageKeys.cartItems);
    if (json == null || json.isEmpty) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveCartItems(List<CartItem> items) async {
    final list = items.map((e) => e.toMap()).toList();
    await _prefs.setString(StorageKeys.cartItems, jsonEncode(list));
  }
}
