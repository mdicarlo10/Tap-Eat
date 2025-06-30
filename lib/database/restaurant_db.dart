import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/restaurant.dart';

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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE restaurants (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        distance TEXT NOT NULL,
        type TEXT NOT NULL,
        imageUrl TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> insert(Restaurant restaurant) async {
    final db = await instance.database;
    await db.insert(
      'restaurants',
      restaurant.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Restaurant>> getAll() async {
    final db = await instance.database;
    final maps = await db.query('restaurants', orderBy: 'id DESC');

    return maps.map((map) => Restaurant.fromMap(map)).toList();
  }

  Future<List<Restaurant>> getHistory({int limit = 10}) async {
    final db = await instance.database;
    final maps = await db.query(
      'restaurants',
      orderBy: 'id DESC',
      limit: limit,
    );

    return maps.map((map) => Restaurant.fromMap(map)).toList();
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
    final db = await instance.database;
    final maps = await db.query(
      'restaurants',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );

    return maps.map((map) => Restaurant.fromMap(map)).toList();
  }
}
