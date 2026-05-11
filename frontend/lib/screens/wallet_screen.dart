import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/stocks_provider.dart';
import '../utils/formatters.dart';
import 'transactions_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WalletProvider, StocksProvider>(
      builder: (context, wallet, stocks, _) {
        double totalPortfolioValue = wallet.holdings.fold(0.0, (sum, holding) {
          final livePrice = stocks.getPriceForSymbol(holding.symbol)
              ?? holding.averageBuyPrice;
          return sum + (holding.quantity * livePrice);
        });

        final totalValue = wallet.balance + totalPortfolioValue;

        return Column(
          children: [
            // ---- BALANCE CARD ----
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatBalance(wallet.balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF30363D)),
                  const SizedBox(height: 8),
                  const Text(
                    'Portfolio Value',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatBalance(totalPortfolioValue),
                    style: const TextStyle(
                      color: Color(0xFF58A6FF),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF30363D)),
                  const SizedBox(height: 8),
                  const Text(
                    'Total Value',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatBalance(totalValue),
                    style: TextStyle(
                      color: compareColor(totalValue, 1000000),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ---- TRANSACTION HISTORY BUTTON ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransactionsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('Transaction History'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Color(0xFF30363D)),
                  ),
                ),
              ),
            ),

            // ---- HOLDINGS HEADER ----
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
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
                    width: 80,
                    child: Text(
                      'Qty',
                      textAlign: TextAlign.center,
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
                      'Value (USD)',
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

            // ---- HOLDINGS LIST ----
            Expanded(
              child: wallet.holdings.isEmpty
                  ? const Center(
                      child: Text(
                        'No holdings yet.\nBuy some stocks to get started!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: wallet.holdings.length,
                      itemBuilder: (context, index) {
                        final holding = wallet.holdings[index];
                        final livePrice =
                            stocks.getPriceForSymbol(holding.symbol)
                                ?? holding.averageBuyPrice;
                        final currentValue = holding.quantity * livePrice;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          holding.symbol,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Avg: \$${holding.averageBuyPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      holding.quantity.toStringAsFixed(0),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 110,
                                    child: Text(
                                      '\$${currentValue.toStringAsFixed(2)}',
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
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