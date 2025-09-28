import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/order_models.dart';

class OrdersDao {
  final Database db;
  OrdersDao._(this.db);

  static const _dbName = 'ecom.db';

  static Future<OrdersDao> open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    final db = await openDatabase(path, version: 1, onCreate: (d, v) async {
      await _createTables(d);
    }, onUpgrade: (d, oldV, newV) async {
      await _createTables(d);
    });
    await _createTables(db);
    return OrdersDao._(db);
  }

  static Future<void> _createTables(Database d) async {
    await d.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        total REAL NOT NULL,
        item_count INTEGER NOT NULL,
        status TEXT NOT NULL
      );
    ''');
    await d.execute('''
      CREATE TABLE IF NOT EXISTS order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        qty INTEGER NOT NULL,
        image TEXT NOT NULL,
        FOREIGN KEY(order_id) REFERENCES orders(id) ON DELETE CASCADE
      );
    ''');
  }

  Future<int> insertOrder(OrderSummary order, List<OrderItemModel> items) async {
    return await db.transaction<int>((txn) async {
      final orderId = await txn.insert('orders', {
        'uid': order.uid,
        'created_at': order.createdAt.millisecondsSinceEpoch,
        'total': order.total,
        'item_count': order.itemCount,
        'status': order.status,
      });
      for (final it in items) {
        await txn.insert('order_items', {
          'order_id': orderId,
          'product_id': it.productId,
          'title': it.title,
          'price': it.price,
          'qty': it.qty,
          'image': it.image,
        });
      }
      return orderId;
    });
  }

  Future<List<OrderSummary>> listOrdersByUid(String uid) async {
    final rows = await db.query('orders', where: 'uid = ?', whereArgs: [uid], orderBy: 'created_at DESC');
    return rows.map((r) => OrderSummary(
      id: r['id'] as int,
      uid: r['uid'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
      total: (r['total'] as num).toDouble(),
      itemCount: r['item_count'] as int,
      status: r['status'] as String,
    )).toList();
  }

  Future<List<OrderItemModel>> getOrderItems(int orderId) async {
    final rows = await db.query('order_items', where: 'order_id = ?', whereArgs: [orderId]);
    return rows.map((r) => OrderItemModel(
      id: r['id'] as int,
      orderId: r['order_id'] as int,
      productId: r['product_id'] as int,
      title: r['title'] as String,
      price: (r['price'] as num).toDouble(),
      qty: r['qty'] as int,
      image: r['image'] as String,
    )).toList();
  }
}
