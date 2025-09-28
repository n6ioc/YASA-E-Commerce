import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';

class CartController extends ChangeNotifier {
  final StorageService storage;
  final FirebaseService firebase;
  CartController({required this.storage, required this.firebase});

  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  double get subtotal =>
      _items.fold(0.0, (s, e) => s + e.product.price * e.quantity);

  Future<void> restore() async {
    final saved = await storage.loadCart();
    _items..clear()..addAll(saved);
    notifyListeners();
  }

  Future<void> add(Product product, {int qty = 1}) async {
    final idx = _items.indexWhere((e) => e.product.id == product.id);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + qty);
    } else {
      _items.add(CartItem(product: product, quantity: qty));
    }
    await _persist();
    firebase.logEvent('cart_add', {'product_id': product.id});
  }

  Future<void> remove(int productId) async {
    _items.removeWhere((e) => e.product.id == productId);
    await _persist();
    firebase.logEvent('cart_remove', {'product_id': productId});
  }

  Future<void> updateQty(int productId, int qty) async {
    final idx = _items.indexWhere((e) => e.product.id == productId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: qty.clamp(1, 99));
      await _persist();
    }
  }

  Future<void> clear() async {
    _items.clear();
    await _persist();
  }

  Future<void> _persist() async {
    await storage.saveCart(_items);
    notifyListeners();
  }
}