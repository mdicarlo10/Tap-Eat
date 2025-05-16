import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/restaurant.dart';

class RestaurantDatabase {
  static final RestaurantDatabase instance = RestaurantDatabase.init();
  static Database? _database;

  RestaurantDatabase.init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB('Ristorande.db');
    return _database!;
  }

  Future<Database> initDB(String filePath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filePath);

    return await openDatabase(path, version: 1, onCreate: createDB);
  }

  Future createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE restaurant_history (
        id $idType,
        name $textType,
        distance $textType,
        type $textType,
        latitude $doubleType,
        longitude $doubleType,
        address TEXT,
        imageUrl TEXT,
        rating REAL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<int> addToHistory(Restaurant restaurant) async {
    final db = await database;

    final maps = await db.query(
      'restaurant_history',
      columns: ['id'],
      where: 'name = ? AND latitude = ? AND longitude = ?',
      whereArgs: [restaurant.name, restaurant.latitude, restaurant.longitude],
    );

    if (maps.isNotEmpty) {
      await db.update(
        'restaurant_history',
        {'timestamp': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [maps.first['id']],
      );
      return maps.first['id'] as int;
    } else {
      final restaurantMap = restaurant.toMap();
      restaurantMap['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      return await db.insert('restaurant_history', restaurantMap);
    }
  }

  Future<List<Restaurant>> getHistory({int limit = 10}) async {
    final db = await database;

    final orderBy = 'timestamp DESC';
    final result = await db.query(
      'restaurant_history',
      orderBy: orderBy,
      limit: limit,
    );

    return result.map((json) => Restaurant.fromMap(json)).toList();
  }

  Future<int> deleteFromHistory(int id) async {
    final db = await database;

    return await db.delete(
      'restaurant_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearHistory() async {
    final db = await database;
    return await db.delete('restaurant_history');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
