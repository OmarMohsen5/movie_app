import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:movie_app/Models/movie_list_item.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();

  Database? _db;

  Future get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return databaseFactory.openDatabase(
        'movie_app.db',
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
    } 
    
    final path = join(await getDatabasesPath(), 'movie_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    return db.execute('''
      CREATE TABLE movie_list_items (
        movieId INTEGER NOT NULL,
        title TEXT NOT NULL,
        posterPath TEXT,
        listType TEXT NOT NULL,
        userId TEXT NOT NULL,
        PRIMARY KEY (movieId, listType, userId)
      )
    ''');
  }

  Future<void> addToList(MovieListItem item) async {
    final db = await database;
    await db.insert(
      'movie_list_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromList(int movieId, ListType type, String userId) async {
    final db = await database;
    await db.delete(
      'movie_list_items',
      where: 'movieId = ? AND listType = ? AND userId = ?',
      whereArgs: [movieId, type.dbValue, userId],
    );
  }

  Future<bool> isInList(int movieId, ListType type, String userId) async {
    final db = await database;
    final rows = await db.query(
      'movie_list_items',
      where: 'movieId = ? AND listType = ? AND userId = ?',
      whereArgs: [movieId, type.dbValue, userId],
    );
    return rows.isNotEmpty;
  }

  Future<List<MovieListItem>> getList(ListType type, String userId) async {
    final db = await database;
    final rows = await db.query(
      'movie_list_items',
      where: 'listType = ? AND userId = ?',
      whereArgs: [type.dbValue, userId],
    );
    
    return List.from(rows.map((r) => MovieListItem.fromMap(r)));
  }
}
