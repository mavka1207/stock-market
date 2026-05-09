import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/stocks_provider.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';

class TradeScreen extends StatefulWidget {
  static const routeName = '/trade';

  final String? preSelectedSymbol;

  const TradeScreen({super.key, this.preSelectedSymbol});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  final _quantityController = TextEditingController();
  bool _isBuying = true;
  String? _selectedSymbol;

  @override
  void initState() {
    super.initState();
    _selectedSymbol = widget.preSelectedSymbol ?? watchlist.first;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Color get _tradeColor => _isBuying ? const Color(0xFF00C853) : const Color(0xFFFF1744);

  Future<void> _confirm() async {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    final currentPrice = context.read<StocksProvider>().getPriceForSymbol(_selectedSymbol!) ?? 0.0;

    final wallet = context.read<WalletProvider>();
    String? error;

    if (_isBuying) {
      error = await wallet.buy(_selectedSymbol!, qty, currentPrice);
    } else {
      error = await wallet.sell(_selectedSymbol!, qty, currentPrice);
    }

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      _quantityController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBuying
                ? 'Successfully bought $_selectedSymbol'
                : 'Successfully sold $_selectedSymbol',
          ),
          backgroundColor: _tradeColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    final holding = wallet.holdings.firstWhere(
      (h) => h.symbol == _selectedSymbol,
      orElse: () => Holding(symbol: '', quantity: 0, averageBuyPrice: 0),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── STOCK SELECTOR ──────────────────────────
          if (widget.preSelectedSymbol == null) ...[
            const Text(
              'Select Stock',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSymbol,
                  dropdownColor: const Color(0xFF161B22),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  items: watchlist.map((stock) {
                    return DropdownMenuItem(
                      value: stock,
                      child: Text(stock),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSymbol = value;
                      _quantityController.clear();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── INFO CARDS ──────────────────────────────
          Consumer<StocksProvider>(
            builder: (context, stocks, _) {
              final currentPrice = stocks.getPriceForSymbol(_selectedSymbol!) ?? 0.0;
              final direction = stocks.getPriceDirection(_selectedSymbol!);
              final color = priceDirectionColor(direction);
              final change = stocks.getPriceChange(_selectedSymbol!);

              return Row(
                children: [
                  // live price card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF30363D)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Price',
                              style: TextStyle(color: Colors.white54, fontSize: 11)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '\$${currentPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                change == null
                                    ? ''
                                    : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}',
                                style: TextStyle(color: color, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // your existing holdings and balance cards stay the same
                  _infoCard('Your Holdings', '${holding.quantity.toStringAsFixed(0)} shares'),
                  const SizedBox(width: 12),
                  _infoCard('Balance', formatBalance(wallet.balance)),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // ── BUY / SELL TOGGLE ───────────────────────
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isBuying = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isBuying
                          ? _tradeColor
                          : const Color(0xFF30363D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'BUY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isBuying = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isBuying
                          ? _tradeColor
                          : const Color(0xFF30363D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'SELL',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── QUANTITY INPUT ───────────────────────────
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Quantity',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF30363D)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF58A6FF)),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // ── TOTAL COST ──────────────────────────────
          Consumer<StocksProvider>(
            builder: (context, stocks, _) {
              final currentPrice = stocks.getPriceForSymbol(_selectedSymbol!) ?? 0.0;
              final qty = double.tryParse(_quantityController.text) ?? 0;
              final totalCost = qty * currentPrice;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total cost',
                        style: TextStyle(color: Colors.white70, fontSize: 15)),
                    Text('\$${totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // ── CONFIRM BUTTON ───────────────────────────
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _tradeColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _confirm,
            child: Text(
              _isBuying
                  ? 'Confirm Buy $_selectedSymbol'
                  : 'Confirm Sell $_selectedSymbol',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── helper widget ──────────────────────────────────
  Widget _infoCard(String label, String value){
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}