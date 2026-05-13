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

    final lineColor = Color(0xFF58A6FF);

    final minX = data.first.date.millisecondsSinceEpoch.toDouble();
    final maxX = data.last.date.millisecondsSinceEpoch.toDouble();

    final prices = data.map((p) => p.close).toList();

    final rawMinY = prices.reduce((a, b) => a < b ? a : b);
    final rawMaxY = prices.reduce((a, b) => a > b ? a : b);

    final yRange = rawMaxY == rawMinY ? 1.0 : rawMaxY - rawMinY;
    final yPadding = yRange * 0.01;
    final minY = rawMinY - yPadding;
    final maxY = rawMaxY + yPadding;

    final range = maxX - minX;
    final isWeeklyView = data.length <= 7;
    final padding = isWeeklyView ? range * 0.02 : range * 0.02;

    // ── Convert PricePoint data to FlSpot for the chart ──
    final spots = data
        .map((p) => FlSpot(
              p.date.millisecondsSinceEpoch.toDouble(),
              p.close,
            ))
        .toList();

    // ── Determine label dates for x axis ──
    final List<DateTime> labelDates;
    if (isWeeklyView) {
      labelDates = [
        data.first.date,
        data.last.date,
      ];
    } else {
      final step = ((data.length - 1) / 3).round();
      labelDates = [
        data[0].date,
        data[(step).clamp(0, data.length - 1)].date,
        data[(step * 2).clamp(0, data.length - 1)].date,
        data[data.length - 1].date,
      ];
    }

    return Column(
      children: [
        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              minX: minX - padding,
              maxX: maxX + padding,
              minY: minY,
              maxY: maxY,
              clipData: const FlClipData.horizontal(),

              // ── GRID LINES ──
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Color(0x1AFFFFFF),
                  strokeWidth: 1,
                ),
              ),

              // ── AXES & BORDERS ──
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                // --- Price labels on y axis ---
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    minIncluded: true,
                    maxIncluded: true,
                    getTitlesWidget: (value, meta) {
                      final axisRange = meta.max - meta.min;
                      final epsilon = axisRange * 0.001;
                      final edgeGap = axisRange * 0.08; // hide labels too close to top/bottom

                      final isBottom = (value - meta.min).abs() < epsilon;
                      final isTop = (value - meta.max).abs() < epsilon;

                      if (isBottom) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '\$${rawMinY.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }

                      if (isTop) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '\$${rawMaxY.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }

                      final tooCloseToBottom = (value - meta.min) < edgeGap;
                      final tooCloseToTop = (meta.max - value) < edgeGap;

                      if (tooCloseToBottom || tooCloseToTop) {
                        return const SizedBox.shrink();
                      }

                      final label = value < 100
                          ? '\$${value.toStringAsFixed(2)}'
                          : '\$${value.toStringAsFixed(0)}';

                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),                // rightTitles: AxisTitles(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                // ── Date labels on x axis ──
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),

              // ── Line bars ──
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  preventCurveOvershootingThreshold: 10,
                  curveSmoothness: 0.18,
                  color: lineColor,
                  barWidth: 1.5,
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

              // ── Touch spots ──
              lineTouchData: LineTouchData(
                getTouchedSpotIndicator: (barData, spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: lineColor,
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: lineColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    );
                  }).toList();
                },

                // ── Touch tooltip ──
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
        ),

        // ── Manual date labels row ──
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,          
            children: labelDates.map((dt) => Text(
              '${dt.day}/${dt.month}',
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            )).toList(),
          ),
        ),
      ],
    );
  }
}