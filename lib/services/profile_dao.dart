import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/user_profile_local.dart';

class ProfileDao {
  final Database db;
  ProfileDao._(this.db);

  static const _dbName = 'ecom.db';

  static Future<ProfileDao> open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    final db = await openDatabase(path, version: 1, onConfigure: (d) async {
      // No-op
    }, onCreate: (d, v) async {
      // If DB is new and created here, create table.
      await _createTable(d);
    }, onUpgrade: (d, oldV, newV) async {
      await _createTable(d);
    });
    // Ensure table exists if DB was created elsewhere.
    await _createTable(db);
    return ProfileDao._(db);
  }

  static Future<void> _createTable(Database d) async {
    await d.execute('''
      CREATE TABLE IF NOT EXISTS user_profile (
        uid TEXT PRIMARY KEY,
        email TEXT,
        name TEXT NOT NULL DEFAULT '',
        address TEXT NOT NULL DEFAULT '',
        updated_at INTEGER NOT NULL DEFAULT 0
      );
    ''');
  }

  Future<UserProfileLocal?> getByUid(String uid) async {
    final rows = await db.query('user_profile', where: 'uid = ?', whereArgs: [uid], limit: 1);
    if (rows.isEmpty) return null;
    return UserProfileLocal.fromMap(rows.first);
    }

  Future<void> upsert(UserProfileLocal u) async {
    await db.insert('user_profile', u.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
