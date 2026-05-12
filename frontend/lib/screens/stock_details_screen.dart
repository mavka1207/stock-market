import 'package:flutter/material.dart';

class StockDetailsScreen extends StatelessWidget {
  static const routeName = '/stock-details';

  final String symbol;

  const StockDetailsScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(symbol),
      ),
      body: Center(
        child: Text(
          '$symbol — coming soon',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}