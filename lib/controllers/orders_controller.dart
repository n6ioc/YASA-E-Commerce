import 'package:flutter/foundation.dart';
import '../models/order_models.dart';
import '../services/storage_service.dart';

class OrdersController extends ChangeNotifier {
  final StorageService storage;
  OrdersController({required this.storage});

  bool _loading = false;
  Object? _error;
  List<OrderSummary> _orders = const [];
  List<OrderItemModel> _items = const [];
  // Local cache: orderId -> items
  final Map<int, List<OrderItemModel>> _itemsByOrder = {};

  bool get loading => _loading;
  Object? get error => _error;
  List<OrderSummary> get orders => _orders;
  List<OrderItemModel> get items => _items;

  Future<void> loadForUser(String uid) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final list = await storage.loadOrdersFor(uid);
      // Rebuild caches
      _orders = list.map((e) => e.$1).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _itemsByOrder
        ..clear();
      for (final pair in list) {
        _itemsByOrder[pair.$1.id] = pair.$2;
      }
    } catch (e) { _error = e; }
    finally { _loading = false; notifyListeners(); }
  }

  Future<void> loadOrderDetail(int orderId) async {
    _loading = true; _error = null; notifyListeners();
    try {
      _items = List.unmodifiable(_itemsByOrder[orderId] ?? const []);
    } catch (e) { _error = e; }
    finally { _loading = false; notifyListeners(); }
  }

  Future<int> placeOrder({required String uid, required double total, required List<OrderItemModel> items}) async {
    // Load existing
    final existing = await storage.loadOrdersFor(uid);
    final maxId = existing.isEmpty ? 0 : existing.map((e) => e.$1.id).reduce((a, b) => a > b ? a : b);
    final newId = maxId + 1;
    final order = OrderSummary(
      id: newId,
      uid: uid,
      createdAt: DateTime.now(),
      total: total,
      itemCount: items.fold<int>(0, (a, b) => a + b.qty),
      status: 'placed',
    );
    final withIds = items
        .map((e) => OrderItemModel(
              id: e.id,
              orderId: newId,
              productId: e.productId,
              title: e.title,
              price: e.price,
              qty: e.qty,
              image: e.image,
            ))
        .toList();
    final updated = [...existing, (order, withIds)];
    await storage.saveOrdersFor(uid, updated);
    // Refresh caches
    await loadForUser(uid);
    return newId;
  }
}
