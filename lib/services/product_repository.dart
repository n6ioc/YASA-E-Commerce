import '../models/product.dart';
import '../services/api_service.dart';
import 'product_dao_single.dart';

class ProductRepository {
  final ProductDaoBase dao;
  ProductRepository._(this.dao);

  static Future<ProductRepository> open() async {
    final dao = await openProductDao();
    return ProductRepository._(dao);
  }

  Future<void> refreshFromNetwork(ApiService api) async {
    final items = await api.fetchProducts();
    await dao.upsertProducts(items);
  }

  Future<List<Product>> pagedQuery({
    required String query,
    required String? category,
    required int page,
    required int pageSize,
  }) {
    final offset = (page - 1) * pageSize;
    return dao.query(query: query, category: category, limit: pageSize, offset: offset);
  }

  Future<List<String>> categories() => dao.distinctCategories();
}