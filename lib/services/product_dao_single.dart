import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/product.dart';

// Cross-platform DAO used by the repository.
// Uses SQLite on mobile/desktop and an in-memory list on Web.
abstract class ProductDaoBase {
  Future<void> clear();
  Future<void> upsertProducts(List<Product> items);
  Future<List<String>> distinctCategories();
  Future<List<Product>> query({
    required String query,
    required String? category,
    required int limit,
    required int offset,
  });
}

Future<ProductDaoBase> openProductDao() async {
  if (kIsWeb) return MemoryProductDao.open();
  return SqliteProductDao.open();
}

class SqliteProductDao implements ProductDaoBase {
  final Database db;
  SqliteProductDao._(this.db);

  static const _dbName = 'ecom.db';
  static const _dbVersion = 1;

  static Future<SqliteProductDao> open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    final db = await openDatabase(path, version: _dbVersion, onCreate: (d, v) async {
      await d.execute('''
        CREATE TABLE products(
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          price REAL NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          image TEXT NOT NULL,
          rate REAL NOT NULL,
          count INTEGER NOT NULL
        );
      ''');
      await d.execute('CREATE INDEX idx_products_category ON products(category);');
      await d.execute('CREATE INDEX idx_products_title ON products(title);');
    });
    return SqliteProductDao._(db);
  }

  @override
  Future<void> clear() async { await db.delete('products'); }

  @override
  Future<void> upsertProducts(List<Product> items) async {
    final batch = db.batch();
    for (final p0 in items) {
      batch.insert(
        'products',
        {
          'id': p0.id,
          'title': p0.title,
          'price': p0.price,
          'description': p0.description,
          'category': p0.category,
          'image': p0.image,
          'rate': p0.rating.rate,
          'count': p0.rating.count,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<String>> distinctCategories() async {
    final rows = await db.rawQuery('SELECT DISTINCT category FROM products ORDER BY category');
    return rows.map((e) => e['category'] as String).toList();
  }

  @override
  Future<List<Product>> query({
    required String query,
    required String? category,
    required int limit,
    required int offset,
  }) async {
    final where = <String>[];
    final args  = <Object?>[];

    if (query.trim().isNotEmpty) {
      where.add('(title LIKE ? OR description LIKE ?)');
      final like = '%${query.trim()}%';
      args..add(like)..add(like);
    }
    if (category != null) {
      where.add('category = ?');
      args.add(category);
    }

    final sql = StringBuffer('SELECT * FROM products');
    if (where.isNotEmpty) sql.write(' WHERE ${where.join(" AND ")}');
    sql.write(' ORDER BY id LIMIT ? OFFSET ?');
    args..add(limit)..add(offset);

    final rows = await db.rawQuery(sql.toString(), args);
    return rows.map(_fromRow).toList();
  }

  Product _fromRow(Map<String, Object?> r) => Product(
    id: r['id'] as int,
    title: r['title'] as String,
    price: (r['price'] as num).toDouble(),
    description: r['description'] as String,
    category: r['category'] as String,
    image: r['image'] as String,
    rating: ProductRating(rate: (r['rate'] as num).toDouble(), count: r['count'] as int),
  );
}

class MemoryProductDao implements ProductDaoBase {
  final List<Product> _items;
  MemoryProductDao._(this._items);

  static Future<MemoryProductDao> open() async => MemoryProductDao._(<Product>[]);

  @override
  Future<void> clear() async { _items.clear(); }

  @override
  Future<void> upsertProducts(List<Product> items) async {
    final byId = {for (final p in _items) p.id: p};
    for (final p in items) { byId[p.id] = p; }
    _items
      ..clear()
      ..addAll(byId.values);
  }

  @override
  Future<List<String>> distinctCategories() async {
    final set = <String>{};
    for (final p in _items) { set.add(p.category); }
    final list = set.toList()..sort();
    return list;
  }

  @override
  Future<List<Product>> query({
    required String query,
    required String? category,
    required int limit,
    required int offset,
  }) async {
    Iterable<Product> r = _items;
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      r = r.where((p) => p.title.toLowerCase().contains(q) || p.description.toLowerCase().contains(q));
    }
    if (category != null) {
      r = r.where((p) => p.category == category);
    }
    final list = r.toList()..sort((a, b) => a.id.compareTo(b.id));
    final end = (offset + limit) > list.length ? list.length : (offset + limit);
    if (offset >= list.length) return <Product>[];
    return list.sublist(offset, end);
  }
}
