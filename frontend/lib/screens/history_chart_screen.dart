import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../widgets/stock_chart.dart';

class HistoryChartScreen extends StatefulWidget {
  final String symbol;

  const HistoryChartScreen({super.key, required this.symbol});

  @override
  State<HistoryChartScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryChartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory(widget.symbol);
    });
  }

  String _filterLabel(HistoryFilter f) {
    switch (f) {
      case HistoryFilter.day:   return '1W';
      case HistoryFilter.week:  return '1M';
      case HistoryFilter.month: return '3M';
      case HistoryFilter.year:  return '1Y';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: Text('${widget.symbol} — Price History'),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, history, _) {

          // ── Loading state ──
          if (history.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error state ──
          if (history.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.white38, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    history.error!,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF238636)),
                    onPressed: () => history.loadHistory(widget.symbol),
                    child: const Text('Retry',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          // ── Empty state ──
          if (history.filteredData.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bar_chart, color: Colors.white24, size: 48),
                  const SizedBox(height: 12),
                  const Text('No historical data available.',
                      style: TextStyle(color: Colors.white38, fontSize: 14)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF238636)),
                    onPressed: () => history.loadHistory(widget.symbol),
                    child: const Text('Retry',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final data = history.filteredData;
          final isUp = history.priceChange >= 0;
          final changeColor =
              isUp ? const Color(0xFF00C853) : const Color(0xFFFF1744);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── STATS ROW ──
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statItem('Lowest', '\$${history.minPrice.toStringAsFixed(2)}'),
                    _statItem('Highest', '\$${history.maxPrice.toStringAsFixed(2)}'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Change',
                            style: TextStyle(color: Colors.white54, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          '${isUp ? '+' : ''}${history.priceChange.toStringAsFixed(2)} '
                          '(${history.priceChangePercent.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            color: changeColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── FILTER CHIPS ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: HistoryFilter.values.map((f) {
                    final selected = history.filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => history.setFilter(f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF58A6FF)
                                : const Color(0xFF21262D),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF58A6FF)
                                  : const Color(0xFF30363D),
                            ),
                          ),
                          child: Text(
                            _filterLabel(f),
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white54,
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // ── STOCK CHART WIDGET ──
              Padding(
                padding: const EdgeInsets.only(left: 26, right: 0),
                child: StockChart(data: data, symbol: widget.symbol),
              ),

              const SizedBox(height: 20),

              // ── TABLE HEADER ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Price History',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                color: const Color(0xFF161B22),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text('Date',
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text('Close',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 68),
                  ],
                ),
              ),

              // ── TABLE ROWS ──
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: data.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Color(0xFF21262D)),
                  itemBuilder: (context, i) {
                    final point = data[data.length - 1 - i];
                    final prevIndex = data.length - 2 - i;
                    final prevClose = prevIndex >= 0
                        ? data[prevIndex].close
                        : point.close;
                    final rowChange = point.close - prevClose;
                    final rowUp = rowChange >= 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${point.date.year}-'
                              '${point.date.month.toString().padLeft(2, '0')}-'
                              '${point.date.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ),
                          Text(
                            '\$${point.close.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            width: 68,
                            child: Text(
                              i == data.length - 1
                                  ? ''
                                  : '${rowUp ? '+' : ''}${rowChange.toStringAsFixed(2)}',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: rowUp
                                    ? const Color(0xFF00C853)
                                    : const Color(0xFFFF1744),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

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
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}