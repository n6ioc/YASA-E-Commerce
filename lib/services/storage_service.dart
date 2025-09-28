import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_preferences.dart';
import '../models/cart_item.dart';
import '../models/order_models.dart';

class StorageService {
  static const _prefsKey = 'app_prefs_v1';
  static const _cartKey  = 'cart_items_v1';
  static const _filtersKey = 'product_filters_v1';
  static const _userDataKey = 'user_data_v1';
  static const _ordersKeyPrefix = 'orders_v1_'; // per-uid storage key

  final SharedPreferences _sp;
  StorageService._(this._sp);

  static Future<StorageService> create() async {
    final sp = await SharedPreferences.getInstance();
    return StorageService._(sp);
  }

  Future<AppPreferences> loadPreferences() async {
    final raw = _sp.getString(_prefsKey);
    return AppPreferences.fromJson(raw != null ? jsonDecode(raw) : null);
  }

  Future<void> savePreferences(AppPreferences prefs) async {
    await _sp.setString(_prefsKey, jsonEncode(prefs.toJson()));
  }

  Future<void> saveCart(List<CartItem> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _sp.setString(_cartKey, encoded);
  }

  Future<List<CartItem>> loadCart() async {
    final raw = _sp.getString(_cartKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((j) => CartItem.fromJson(j)).toList();
  }

  // Persist product filters (search query and selected category)
  Future<void> saveProductFilters({required String query, String? category}) async {
    final data = {'query': query, 'category': category};
    await _sp.setString(_filtersKey, jsonEncode(data));
  }

  Future<(String, String?)> loadProductFilters() async {
    final raw = _sp.getString(_filtersKey);
    if (raw == null) return ('', null);
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return ((j['query'] as String?) ?? '', j['category'] as String?);
  }

  // Persist basic user profile data locally
  Future<void> saveUserData({required String email, required String name, required String address}) async {
    final data = {'email': email, 'name': name, 'address': address};
    await _sp.setString(_userDataKey, jsonEncode(data));
  }

  Future<Map<String, String>?> loadUserData() async {
    final raw = _sp.getString(_userDataKey);
    if (raw == null) return null;
    final j = (jsonDecode(raw) as Map).cast<String, dynamic>();
    return {
      'email': (j['email'] as String?) ?? '',
      'name': (j['name'] as String?) ?? '',
      'address': (j['address'] as String?) ?? '',
    };
  }

  // Orders stored in SharedPreferences as a JSON array of objects
  // Each element: { "order": OrderSummary.toJson(), "items": [OrderItemModel.toJson(), ...] }
  Future<List<(OrderSummary, List<OrderItemModel>)>> loadOrdersFor(String uid) async {
    final key = '$_ordersKeyPrefix$uid';
    final raw = _sp.getString(key);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map<(OrderSummary, List<OrderItemModel>)>((m) {
      final o = OrderSummary.fromJson((m['order'] as Map).cast<String, dynamic>());
      final items = ((m['items'] as List).cast<Map<String, dynamic>>())
          .map((j) => OrderItemModel.fromJson(j))
          .toList();
      return (o, items);
    }).toList();
  }

  Future<void> saveOrdersFor(String uid, List<(OrderSummary, List<OrderItemModel>)> orders) async {
    final key = '$_ordersKeyPrefix$uid';
    final data = orders
        .map((e) => {
              'order': e.$1.toJson(),
              'items': e.$2.map((i) => i.toJson()).toList(),
            })
        .toList();
    await _sp.setString(key, jsonEncode(data));
  }
}