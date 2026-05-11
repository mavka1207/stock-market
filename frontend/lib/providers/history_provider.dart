import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PricePoint {
  final DateTime date;
  final double close;

  PricePoint({
    required this.date,
    required this.close,
  });

  factory PricePoint.fromMap(Map<String, dynamic> map) {
    return PricePoint(
      date: DateTime.parse(map['date']),
      close: (map['close'] as num).toDouble(),
    );
  }
}

enum HistoryFilter { day, week, month, year }

class HistoryProvider extends ChangeNotifier {
  List<PricePoint> _allData = [];
  List<PricePoint> _filteredData = [];
  String? _currentSymbol;
  HistoryFilter _filter = HistoryFilter.month;
  bool _isLoading = false;
  String? _error;

  List<PricePoint> get filteredData => _filteredData;
  List<PricePoint> get allData => _allData;
  String? get currentSymbol => _currentSymbol;
  HistoryFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load history for selected stock
  Future<void> loadHistory(String symbol) async {
    _isLoading = true;
    _error = null;
    _currentSymbol = symbol;
    notifyListeners();

    try {
      // Loading data for the last year
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 365));

      final url = Uri.parse(
        'http://localhost:5001/hist/$symbol'
        '?start_date=${_formatDate(startDate)}'
        '&end_date=${_formatDate(endDate)}',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final values = data['values'] as List<dynamic>;

        _allData = values
            .map((v) => PricePoint.fromMap(v))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

        // Applying current filter
        _applyFilter();
      } else {
        _error = 'Failed to load history for $symbol';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Apply filter (day / week / month / year)
  void setFilter(HistoryFilter newFilter) {
    _filter = newFilter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_allData.isEmpty) {
      _filteredData = [];
      return;
    }

    final now = DateTime.now();
    DateTime cutoff;

    switch (_filter) {
      case HistoryFilter.day:
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case HistoryFilter.week:
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case HistoryFilter.month:
        cutoff = now.subtract(const Duration(days: 90));
        break;
      case HistoryFilter.year:
        cutoff = now.subtract(const Duration(days: 365));
        break;
    }

    _filteredData = _allData
        .where((p) => p.date.isAfter(cutoff))
        .toList();

    // If there is no data after filtering, show all data
    if (_filteredData.isEmpty) {
      _filteredData = List.from(_allData);
    }
  }

  // Formatting date for API
  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // Minimum price in filtered data
  double get minPrice {
    if (_filteredData.isEmpty) return 0;
    return _filteredData
        .map((p) => p.close)
        .reduce((a, b) => a < b ? a : b);
  }

  // Maximum price in filtered data
  double get maxPrice {
    if (_filteredData.isEmpty) return 0;
    return _filteredData
        .map((p) => p.close)
        .reduce((a, b) => a > b ? a : b);
  }

  // Price change over the period
  double get priceChange {
    if (_filteredData.length < 2) return 0;
    return _filteredData.last.close - _filteredData.first.close;
  }

  // Percentage price change
  double get priceChangePercent {
    if (_filteredData.length < 2) return 0;
    final first = _filteredData.first.close;
    if (first == 0) return 0;
    return (priceChange / first) * 100;
  }

  // Clear when changing stock
  void clear() {
    _allData = [];
    _filteredData = [];
    _currentSymbol = null;
    _error = null;
    notifyListeners();
  }
}