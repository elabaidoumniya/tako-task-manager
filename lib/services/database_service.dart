// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../models/category.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'task_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Table catégories
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        colorValue INTEGER NOT NULL,
        icon TEXT NOT NULL,
        userId TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    // Table tâches
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        priority INTEGER NOT NULL DEFAULT 1,
        status INTEGER NOT NULL DEFAULT 0,
        categoryId TEXT,
        createdAt TEXT NOT NULL,
        dueDate TEXT,
        userId TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');
  }

  // ===================== USERS =====================

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query('users',
        where: 'email = ?', whereArgs: [email], limit: 1);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await database;
    final maps =
        await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  // ===================== TASKS =====================

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTasksByUser(String userId) async {
    final db = await database;
    final maps = await db.query('tasks',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update('tasks', task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ===================== CATEGORIES =====================

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getCategoriesByUser(String userId) async {
    final db = await database;
    final maps = await db.query('categories',
        where: 'userId = ?', whereArgs: [userId]);
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
