import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class StockPrice {
  final String symbol;
  final double rate;
  final String currency;
  final String datetime;

  StockPrice({
    required this.symbol,
    required this.rate,
    required this.currency,
    required this.datetime,
  });
}

class StocksProvider extends ChangeNotifier {
  final Map<String, StockPrice> _prices = {};
  final Map<String, double> _previousPrices = {};
  Timer? _timer;
  bool _isLoading = false;
  String? _error;

  Map<String, StockPrice> get prices => _prices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // price of one stock
  StockPrice? getPrice(String symbol) => _prices[symbol];

  // all prices as list
  List<StockPrice> get allPrices => watchlist
      .where((s) => _prices.containsKey(s))
      .map((s) => _prices[s]!)
      .toList();

  // shows if the stock price is rising or falling
  // true = rising, false = falling, null = no data
  bool? getPriceDirection(String symbol) {
    final current = _prices[symbol]?.rate;
    final previous = _previousPrices[symbol];
    if (current == null || previous == null) return null;
    if (current > previous) return true;
    if (current < previous) return false;
    return null;
  }

  // shows how much the price changed
  double? getPriceChange(String symbol) {
    final current = _prices[symbol]?.rate;
    final previous = _previousPrices[symbol];

    if (current == null || previous == null) return null;
    return current - previous;
  }

  // get price of one stock from mock-server
  Future<void> _fetchPrice(String symbol) async {
    try {

      // ------ MAIRE's SETUP FOR ANDROID EMULATOR ------
      String baseUrl;
      if (Platform.isAndroid) {
        baseUrl = 'http://10.0.2.2:5001';
      } else {
        baseUrl = 'http://127.0.0.1:5001';
      }

      final response = await http
          .get(Uri.parse('$baseUrl/exchange_rate/$symbol'))
          .timeout(const Duration(milliseconds: 500));


      // ------ ORIGINAL CODE ------
      // final response = await http.get(
      //   Uri.parse('http://localhost:5001/exchange_rate/$symbol'),
      // ).timeout(const Duration(milliseconds: 500));
      

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // save previous price if exists
        if (_prices.containsKey(symbol)) {
          _previousPrices[symbol] = _prices[symbol]!.rate;
        }
        // update current price
        _prices[symbol] = StockPrice(
          symbol: symbol,
          rate: (data['rate'] as num).toDouble(),
          currency: data['currency'] ?? 'USD',
          datetime: data['datetime'] ?? '',
        );
      }
    } catch (e) {
      _error = 'Failed to fetch $symbol';
    }
  }

  // get prices of all 20 stocks
  Future<void> fetchAllPrices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.wait(
      watchlist.map((symbol) => _fetchPrice(symbol)),
    );

    _isLoading = false;
    notifyListeners();
  }

  // start real-time updates 5 times per second
  void startRealTimeUpdates() {
    _timer?.cancel();
    fetchAllPrices(); // first request
    _timer = Timer.periodic(
      const Duration(milliseconds: 1000), // testing with 1s interval
      // const Duration(milliseconds: 200), // 5 times per second
      (_) async {
        await Future.wait(
          watchlist.map((symbol) => _fetchPrice(symbol)),
        );
        notifyListeners();
      },
    );
  }

  double? getPriceForSymbol(String symbol) {
    try {
      return allPrices.firstWhere((s) => s.symbol == symbol).rate;
    } catch (_) {
      return null;
    }
  }
  // stop real-time updates (at logout)
  void stopRealTimeUpdates() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}