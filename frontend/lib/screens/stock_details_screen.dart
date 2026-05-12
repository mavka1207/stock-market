import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/stocks_provider.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';
import 'trade_screen.dart';
import 'transactions_screen.dart';
import 'history_chart_screen.dart';

class StockDetailsScreen extends StatelessWidget {
  static const routeName = '/stock-details';

  final String symbol;

  const StockDetailsScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: Text(symbol),
      ),
      body: Consumer2<StocksProvider, WalletProvider>(
        builder: (context, stocks, wallet, _) {
          final price = stocks.getPriceForSymbol(symbol);
          final direction = stocks.getPriceDirection(symbol);
          final change = stocks.getPriceChange(symbol);

          // ── Loading state ──
          if (price == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final priceColor = priceDirectionColor(direction);

          final holding = wallet.holdings.firstWhere(
            (h) => h.symbol == symbol,
            orElse: () => Holding(symbol: '', quantity: 0, averageBuyPrice: 0),
          );

          final holdingValue = holding.quantity * price;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── PRICE CARD ──────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF30363D)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$symbol • ${getStockName(symbol)}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            direction == 'up'
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: priceColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            change == null
                                ? '--'
                                : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}',
                            style: TextStyle(color: priceColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── HOLDINGS CARD ───────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF30363D)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statItem(
                        'Shares Owned',
                        holding.quantity.toStringAsFixed(0),
                      ),
                      _statItem(
                        'Avg. Buy Price',
                        holding.quantity > 0
                            ? '\$${holding.averageBuyPrice.toStringAsFixed(2)}'
                            : '--',
                      ),
                      _statItem(
                        'Market Value',
                        holding.quantity > 0
                            ? '\$${holdingValue.toStringAsFixed(2)}'
                            : '--',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── BUY / SELL BUTTON ───────────────────────
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF238636),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        backgroundColor: const Color(0xFF0D1117),
                        appBar: AppBar(
                          backgroundColor: const Color(0xFF161B22),
                          title: Text('Trade $symbol'),
                        ),
                        body: TradeScreen(preSelectedSymbol: symbol),
                      ),
                    ),
                  ),                  
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_shopping_cart, size: 18),
                      SizedBox(width: 8),
                      Text('Buy / Sell'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── PRICE HISTORY TILE ──────────────────────
                _navTile(
                  icon: Icons.show_chart,
                  iconColor: const Color(0xFF58A6FF),
                  title: 'Price History Chart',
                  subtitle: 'View $symbol price over time',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryChartScreen(symbol: symbol),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── TRANSACTION HISTORY TILE ────────────────
                _navTile(
                  icon: Icons.receipt_long_outlined,
                  iconColor: const Color(0xFFE3B341),
                  title: 'Transaction History',
                  subtitle: 'All your past buys & sells',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransactionsScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── BALANCE FOOTER ──────────────────────────
                Text(
                  'Available balance: ${formatBalance(wallet.balance)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Stat column helper ──────────────────────────────
  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  // ── Navigation tile helper ──────────────────────────
  Widget _navTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }
}