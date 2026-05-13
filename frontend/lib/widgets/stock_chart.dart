import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/history_provider.dart';

class StockChart extends StatelessWidget {
  final List<PricePoint> data;
  final String symbol;

  const StockChart({
    super.key,
    required this.data,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 260,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart, color: Colors.white24, size: 40),
              SizedBox(height: 8),
              Text(
                'No data for this period',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final isUp = data.last.close >= data.first.close;
    final lineColor =
        isUp ? const Color(0xFF00C853) : const Color(0xFFFF1744);

    final minX = data.first.date.millisecondsSinceEpoch.toDouble();
    final maxX = data.last.date.millisecondsSinceEpoch.toDouble();

    final prices = data.map((p) => p.close).toList();
    final minY = prices.reduce((a, b) => a < b ? a : b) * 0.98;
    final maxY = prices.reduce((a, b) => a > b ? a : b) * 1.02;
    final range = maxX - minX;
    final padding = range * 0.02; // 2% padding on each side

    final spots = data
        .map((p) => FlSpot(
              p.date.millisecondsSinceEpoch.toDouble(),
              p.close,
            ))
        .toList();

    return SizedBox(
      height: 260,
      child: LineChart(
        // ----- MAIN CHART DATA -----
        LineChartData(
          minX: minX - padding,
          maxX: maxX + padding,
          minY: minY,
          maxY: maxY,
          clipData: const FlClipData.all(),

          // ----- horizontal grid lines only, no vertical lines -----
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Color(0x1AFFFFFF),
              strokeWidth: 1,
            ),
          ),

          // ----- hide border around the chart -----
          borderData: FlBorderData(show: false),

          // ----- axis titles and labels -----
          titlesData: FlTitlesData(
            // hide y-axis on the left
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            // show price on y-axis
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) => Text(
                  '\$${value.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ),
            ),

            // hide x-axis line and labels
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            // show date on x-axis
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: maxX == minX ? 1 : (maxX - minX) / 4,
                getTitlesWidget: (value, meta) {
                  final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${dt.day}/${dt.month}',
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),

          // ----- the line and area below it -----
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: lineColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    lineColor.withValues(alpha: 0.25),
                    lineColor.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],

          // ------ tooltip on touch ------
          lineTouchData: LineTouchData(
            // --- control the touch dot size ---
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: lineColor,
                    strokeWidth: 1,
                    dashArray: [4, 4], // dashed vertical line on touch
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 4, // ── change this to make dot bigger/smaller ──
                      color: lineColor,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFFFF1744),
                    ),
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF21262D),
              getTooltipItems: (spots) => spots.map((s) {
                final dt = DateTime.fromMillisecondsSinceEpoch(s.x.toInt());
                return LineTooltipItem(
                  '${dt.year}-'
                  '${dt.month.toString().padLeft(2, '0')}-'
                  '${dt.day.toString().padLeft(2, '0')}\n'
                  '\$${s.y.toStringAsFixed(2)}',
                  TextStyle(
                    color: lineColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}