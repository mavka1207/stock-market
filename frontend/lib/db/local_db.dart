import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'stock_market.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // USERS
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 1000000.0,
        created_at TEXT NOT NULL
      )
    ''');

    // HOLDINGS
    await db.execute('''
      CREATE TABLE holdings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        symbol TEXT NOT NULL,
        quantity REAL NOT NULL,
        average_buy_price REAL NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // TRANSACTIONS
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        symbol TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity REAL NOT NULL,
        price REAL NOT NULL,
        total REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  // ===========================================
  //USERS
  // ===========================================

  // create user
  static Future<int> createUser({
    required String email,
    required String passwordHash,
  }) async {
    final db = await database;
    return await db.insert('users', {
      'email': email,
      'password_hash': passwordHash,
      'balance': 1000000.0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // get user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  // get user by id
  static Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  // update user balance
  static Future<void> updateBalance({
    required int userId,
    required double newBalance,
  }) async {
    final db = await database;
    await db.update(
      'users',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ─────────────────────────────────────────
  // HOLDINGS
  // ─────────────────────────────────────────

  // get all holdings for user
  static Future<List<Map<String, dynamic>>> getHoldings(int userId) async {
    final db = await database;
    return await db.query(
      'holdings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // get one holding by symbol
  static Future<Map<String, dynamic>?> getHolding({
    required int userId,
    required String symbol,
  }) async {
    final db = await database;
    final result = await db.query(
      'holdings',
      where: 'user_id = ? AND symbol = ?',
      whereArgs: [userId, symbol],
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  // save or update holding
  static Future<void> saveHolding({
    required int userId,
    required String symbol,
    required double quantity,
    required double averageBuyPrice,
  }) async {
    final db = await database;
    final existing = await getHolding(userId: userId, symbol: symbol);

    if (existing == null) {
      // create new holding
      await db.insert('holdings', {
        'user_id': userId,
        'symbol': symbol,
        'quantity': quantity,
        'average_buy_price': averageBuyPrice,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } else {
      // update existing holding
      await db.update(
        'holdings',
        {
          'quantity': quantity,
          'average_buy_price': averageBuyPrice,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ? AND symbol = ?',
        whereArgs: [userId, symbol],
      );
    }
  }

  // delete holding (when sold everything)
  static Future<void> deleteHolding({
    required int userId,
    required String symbol,
  }) async {
    final db = await database;
    await db.delete(
      'holdings',
      where: 'user_id = ? AND symbol = ?',
      whereArgs: [userId, symbol],
    );
  }

  // ─────────────────────────────────────────
  // TRANSACTIONS
  // ─────────────────────────────────────────

  // save transaction (buy or sell)
  static Future<void> saveTransaction({
    required int userId,
    required String symbol,
    required String type, // 'buy' or 'sell'
    required double quantity,
    required double price,
    required double total,
  }) async {
    final db = await database;
    await db.insert('transactions', {
      'user_id': userId,
      'symbol': symbol,
      'type': type,
      'quantity': quantity,
      'price': price,
      'total': total,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // get all transactions for user
  static Future<List<Map<String, dynamic>>> getTransactions(int userId) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }
}