import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import '../core/debouncer.dart';
import '../services/product_repository.dart';
import '../services/storage_service.dart';

class ProductController extends ChangeNotifier {
  final ApiService api;
  final FirebaseService firebase;
  final Debouncer _debounce = Debouncer(delay: const Duration(milliseconds: 300));

  ProductController({required this.api, required this.firebase});

  late ProductRepository _repo;
  final List<Product> _products = [];
  List<String> _categories = [];
  bool _loading = false;
  Object? _error;

  String _query = '';
  String? _category;
  int _page = 1;
  final int _pageSize = 12;
  bool _hasMore = true;
  bool _loadingMore = false;

  List<Product> get products => List.unmodifiable(_products);
  List<String> get categories => ['All', ..._categories];
  String get query => _query;
  String? get category => _category;

  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  Object? get error => _error;

  Future<void> init() async {
    _loading = true; _error = null; notifyListeners();
    try {
      _repo = await ProductRepository.open();
      // Restore persisted filters
      final storage = await StorageService.create();
      final (savedQuery, savedCategory) = await storage.loadProductFilters();
      _query = savedQuery;
      _category = savedCategory;
      _categories = await _repo.categories();
      await _resetAndLoadFirstPage();
      firebase.logEvent('products_init', {});
      await refreshFromNetwork(silent: true);
    } catch (e) {
      _error = e;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> refreshFromNetwork({bool silent = false}) async {
    if (!silent) { _loading = true; _error = null; notifyListeners(); }
    try {
      await _repo.refreshFromNetwork(api);
      _categories = await _repo.categories();
      await _resetAndLoadFirstPage();
      firebase.logEvent('products_refreshed', {});
    } catch (e) {
      _error = e;
    } finally {
      if (!silent) { _loading = false; notifyListeners(); }
    }
  }

  void setQuery(String q) {
    _query = q;
    _debounce.run(() async {
      // Persist filters
      final storage = await StorageService.create();
      await storage.saveProductFilters(query: _query, category: _category);
      await _resetAndLoadFirstPage();
    });
  }

  void setCategory(String? c) async {
    _category = (c == null || c == 'All') ? null : c;
    final storage = await StorageService.create();
    await storage.saveProductFilters(query: _query, category: _category);
    _resetAndLoadFirstPage();
  }

  Future<void> loadMore() async {
    if (!_hasMore || _loadingMore) return;
    _loadingMore = true; notifyListeners();
    try {
      _page += 1;
      final next = await _repo.pagedQuery(
        query: _query, category: _category, page: _page, pageSize: _pageSize,
      );
      _products.addAll(next);
      _hasMore = next.length == _pageSize;
    } catch (e) {
      _error = e;
    } finally {
      _loadingMore = false; notifyListeners();
    }
  }

  Future<void> _resetAndLoadFirstPage() async {
    _page = 1; _products.clear();
    final first = await _repo.pagedQuery(
      query: _query, category: _category, page: _page, pageSize: _pageSize,
    );
    _products.addAll(first);
    _hasMore = first.length == _pageSize;
    notifyListeners();
  }

  Product? byId(int id) =>
      _products.cast<Product?>().firstWhere((p) => p?.id == id, orElse: () => null);

  @override
  void dispose() { _debounce.dispose(); super.dispose(); }
}