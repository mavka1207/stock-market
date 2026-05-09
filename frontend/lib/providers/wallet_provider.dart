import 'package:flutter/material.dart';
import '../db/local_db.dart';

// ── simple model for one holding row ──────────────────────
class Holding {
  final String symbol;
  final double quantity;
  final double averageBuyPrice;

  Holding({
    required this.symbol,
    required this.quantity,
    required this.averageBuyPrice,
  });
}

// ── provider ──────────────────────────────────────────────
class WalletProvider extends ChangeNotifier {
  double _balance = 0;
  List<Holding> _holdings = [];
  int? _userId;

  double get balance => _balance;
  List<Holding> get holdings => _holdings;

  // ── load from DB after login ───────────────────────────
  Future<void> loadWallet(int userId) async {
    _userId = userId;

    // load balance
    final user = await LocalDB.getUserById(userId);
    if (user != null) {
      _balance = user['balance'] as double;
    }

    // load holdings
    final rows = await LocalDB.getHoldings(userId);
    _holdings = rows.map((row) => Holding(
      symbol: row['symbol'] as String,
      quantity: (row['quantity'] as num).toDouble(),
      averageBuyPrice: (row['average_buy_price'] as num).toDouble(),
    )).toList();

    notifyListeners();
  }

  // ── buy ────────────────────────────────────────────────
  Future<String?> buy(String symbol, double quantity, double price) async {
    if (_userId == null) return 'Not logged in';

    final total = quantity * price;

    // check balance
    if (total > _balance) return 'Insufficient balance';

    // calculate new average buy price
    final existing = _holdings.firstWhere(
      (h) => h.symbol == symbol,
      orElse: () => Holding(symbol: symbol, quantity: 0, averageBuyPrice: 0),
    );

    final newQuantity = existing.quantity + quantity;
    final newAverage = existing.quantity == 0
        ? price
        : ((existing.quantity * existing.averageBuyPrice) + (quantity * price))
            / newQuantity;

    // update DB
    final newBalance = _balance - total;
    await LocalDB.updateBalance(userId: _userId!, newBalance: newBalance);
    await LocalDB.saveHolding(
      userId: _userId!,
      symbol: symbol,
      quantity: newQuantity,
      averageBuyPrice: newAverage,
    );
    await LocalDB.saveTransaction(
      userId: _userId!,
      symbol: symbol,
      type: 'buy',
      quantity: quantity,
      price: price,
      total: total,
    );

    // update in-memory state
    _balance = newBalance;
    _holdings = _holdings.where((h) => h.symbol != symbol).toList();
    _holdings.add(Holding(
      symbol: symbol,
      quantity: newQuantity,
      averageBuyPrice: newAverage,
    ));

    notifyListeners();
    return null; // null = success
  }

  // ── sell ───────────────────────────────────────────────
  Future<String?> sell(String symbol, double quantity, double price) async {
    if (_userId == null) return 'Not logged in';

    final existing = _holdings.firstWhere(
      (h) => h.symbol == symbol,
      orElse: () => Holding(symbol: symbol, quantity: 0, averageBuyPrice: 0),
    );

    if (existing.symbol.isEmpty) return 'You do not own this stock';
    // check quantity
    if (existing.quantity < quantity) return 'Not enough shares to sell';

    final total = quantity * price;
    final newQuantity = existing.quantity - quantity;
    final newBalance = _balance + total;

    // update DB
    await LocalDB.updateBalance(userId: _userId!, newBalance: newBalance);

    if (newQuantity < 0.0001) { // use < 0.0001 instead of == 0 to handle floating point
      await LocalDB.deleteHolding(userId: _userId!, symbol: symbol);
    } else {
      await LocalDB.saveHolding(
        userId: _userId!,
        symbol: symbol,
        quantity: newQuantity,
        averageBuyPrice: existing.averageBuyPrice, // avg stays same on sell
      );
    }

    await LocalDB.saveTransaction(
      userId: _userId!,
      symbol: symbol,
      type: 'sell',
      quantity: quantity,
      price: price,
      total: total,
    );

    // update in-memory state
    _balance = newBalance;
    if (newQuantity < 0.0001) { // use < 0.0001 instead of == 0 to handle floating point
      _holdings = _holdings.where((h) => h.symbol != symbol).toList();
    } else {
      _holdings = _holdings.where((h) => h.symbol != symbol).toList();
      _holdings.add(Holding(
        symbol: symbol,
        quantity: newQuantity,
        averageBuyPrice: existing.averageBuyPrice,
      ));
    }

    notifyListeners();
    return null; // null = success
  }

  // ── clear on logout ────────────────────────────────────
  void clear() {
    _balance = 0;
    _holdings = [];
    _userId = null;
    notifyListeners();
  }
}