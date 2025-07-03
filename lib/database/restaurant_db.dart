import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tap_eat/models/restaurant.dart';

class RestaurantDatabase {
  static final RestaurantDatabase instance = RestaurantDatabase._init();

  static Database? _database;

  RestaurantDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('restaurants.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE restaurants (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        distance REAL NOT NULL,
        type TEXT NOT NULL,
        imageUrl TEXT,
        timestamp INTEGER NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> insert(Restaurant restaurant) async {
    final db = await database;
    await db.insert(
      'restaurants',
      restaurant.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await deleteOldestIfLimitExceeded();
  }

  Future<List<Restaurant>> getAll() async {
    final db = await database;
    final maps = await db.query('restaurants', orderBy: 'id DESC');

    return maps.map((map) => Restaurant.fromMap(map)).toList();
  }

  Future<List<Restaurant>> getHistory({int limit = 2}) async {
    final db = await database;
    final maps = await db.query(
      'restaurants',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((map) => Restaurant.fromMap(map)).toList();
  }

  Future<void> deleteOldestIfLimitExceeded() async {
    final db = await database;

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM restaurants'),
    );

    const int maxEntries = 50;

    if (count != null && count > maxEntries) {
      final numberToDelete = count - maxEntries;

      await db.rawDelete(
        '''
        DELETE FROM restaurants 
        WHERE id IN (
          SELECT id FROM restaurants 
          ORDER BY timestamp ASC 
          LIMIT ?
        )
      ''',
        [numberToDelete],
      );
    }
  }

  Future<void> updateFavoriteStatus(
    Restaurant restaurant,
    bool isFavorite,
  ) async {
    final db = await instance.database;
    await db.update(
      'restaurants',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [restaurant.id],
    );
  }

  Future<List<Restaurant>> getFavorites() async {
    final db = await database;
    final maps = await db.query(
      'restaurants',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );

    return maps.map((map) => Restaurant.fromMap(map)).toList();
  }
}
