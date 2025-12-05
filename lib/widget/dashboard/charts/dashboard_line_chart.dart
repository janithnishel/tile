// lib/widgets/dashboard/charts/dashboard_line_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/dashboard/dashboard_models.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class DashboardLineChart extends StatefulWidget {
  final String title;
  final List<LineChartDataPoint> data;
  final Color lineColor;
  final Color gradientColor;
  final bool showGrid;
  final bool showDots;
  final Function(LineChartDataPoint)? onPointTap;
  final double? height;

  const DashboardLineChart({
    Key? key,
    required this.title,
    required this.data,
    this.lineColor = const Color(0xFF7B1FA2),
    this.gradientColor = const Color(0xFF7B1FA2),
    this.showGrid = true,
    this.showDots = true,
    this.onPointTap,
    this.height,
  }) : super(key: key);

  @override
  State<DashboardLineChart> createState() => _DashboardLineChartState();
}

class _DashboardLineChartState extends State<DashboardLineChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.lineColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.show_chart,
                  color: widget.lineColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: ReportTheme.headingSmall,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: widget.height ?? 200,
            child: widget.data.isEmpty
                ? _buildEmptyState()
                : LineChart(_buildLineChartData()),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData() {
    final spots = widget.data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final maxY = widget.data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minY = widget.data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return LineChartData(
      gridData: FlGridData(
        show: widget.showGrid,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: (widget.data.length / 5).ceilToDouble(),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < widget.data.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('dd/MM').format(widget.data[index].date),
                    style: TextStyle(
                      color: ReportTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              return Text(
                _formatValue(value),
                style: TextStyle(
                  color: ReportTheme.textSecondary,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (widget.data.length - 1).toDouble(),
      minY: minY - padding,
      maxY: maxY + padding,
      lineTouchData: LineTouchData(
        touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
          if (event is FlTapUpEvent && response?.lineBarSpots != null) {
            final index = response!.lineBarSpots!.first.spotIndex;
            if (index >= 0 && index < widget.data.length) {
              widget.onPointTap?.call(widget.data[index]);
            }
          }
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => ReportTheme.primaryColor,
          tooltipBorderRadius: BorderRadius.circular(12),
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final index = spot.spotIndex;
              final point = widget.data[index];
              return LineTooltipItem(
                '${DateFormat('dd MMM').format(point.date)}\nRs. ${_formatValue(point.value)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: widget.lineColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: widget.showDots,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: _touchedIndex == index ? 6 : 4,
                color: Colors.white,
                strokeWidth: 3,
                strokeColor: widget.lineColor,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                widget.gradientColor.withOpacity(0.3),
                widget.gradientColor.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No data available',
            style: TextStyle(color: ReportTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
