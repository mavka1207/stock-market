import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stocks_provider.dart';
import '../utils/formatters.dart';
import 'stock_details_screen.dart';

class WatchlistScreen extends StatelessWidget {
  static const routeName = '/watchlist';

  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StocksProvider>(
        builder: (context, stocksProvider, _) {
          if (stocksProvider.isLoading && stocksProvider.allPrices.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (stocksProvider.error != null &&
              stocksProvider.allPrices.isEmpty) {
            return Center(child: Text(stocksProvider.error!));
          }

          final prices = stocksProvider.allPrices; // up to 20 stocks

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF161B22),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF30363D)),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Markets',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: Text(
                        'Current price (USD)',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
                child: ListView.builder(
                  itemCount: prices.length,
                  itemBuilder: (context, index) {
                    final stock = prices[index];
                    final change = stocksProvider.getPriceChange(stock.symbol);
                    final priceColor = priceDirectionColor(stocksProvider.getPriceDirection(stock.symbol));

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute (
                            builder: (context) => StockDetailsScreen(symbol: stock.symbol)
                          )
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stock.symbol,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        change == null
                                            ? 'No change'
                                            : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: priceColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    stock.rate.toStringAsFixed(2),
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: priceColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );        
        },
    );
  }
}