// lib/widgets/dashboard/charts/dashboard_scatter_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tilework/models/dashboard/dashboard_models.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class DashboardScatterChart extends StatefulWidget {
  final String title;
  final String xAxisLabel;
  final String yAxisLabel;
  final List<ScatterDataPoint> data;
  final double? height;
  final Function(ScatterDataPoint)? onPointTap;

  const DashboardScatterChart({
    Key? key,
    required this.title,
    required this.xAxisLabel,
    required this.yAxisLabel,
    required this.data,
    this.height,
    this.onPointTap,
  }) : super(key: key);

  @override
  State<DashboardScatterChart> createState() => _DashboardScatterChartState();
}

class _DashboardScatterChartState extends State<DashboardScatterChart> {
  int _touchedIndex = -1;

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
                  color: ReportTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.scatter_plot,
                  color: ReportTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: ReportTheme.headingSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Axis Labels
          Row(
            children: [
              _buildAxisLabel(widget.xAxisLabel, Icons.arrow_forward),
              const SizedBox(width: 16),
              _buildAxisLabel(widget.yAxisLabel, Icons.arrow_upward),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: widget.height ?? 220,
            child: widget.data.isEmpty
                ? _buildEmptyState()
                : ScatterChart(_buildChartData()),
          ),
        ],
      ),
    );
  }

  Widget _buildAxisLabel(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ReportTheme.accentBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: ReportTheme.accentDark),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: ReportTheme.accentDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  ScatterChartData _buildChartData() {
    final maxX = widget.data.map((e) => e.xValue).reduce((a, b) => a > b ? a : b);
    final minX = widget.data.map((e) => e.xValue).reduce((a, b) => a < b ? a : b);
    final maxY = widget.data.map((e) => e.yValue).reduce((a, b) => a > b ? a : b);
    final minY = widget.data.map((e) => e.yValue).reduce((a, b) => a < b ? a : b);
    
    final xPadding = (maxX - minX) * 0.1;
    final yPadding = (maxY - minY) * 0.1;

    return ScatterChartData(
      minX: minX - xPadding,
      maxX: maxX + xPadding,
      minY: minY - yPadding,
      maxY: maxY + yPadding,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
        getDrawingVerticalLine: (value) {
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
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _formatValue(value),
                  style: TextStyle(
                    fontSize: 10,
                    color: ReportTheme.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            getTitlesWidget: (value, meta) {
              return Text(
                _formatValue(value),
                style: TextStyle(
                  fontSize: 10,
                  color: ReportTheme.textSecondary,
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      scatterTouchData: ScatterTouchData(
        touchCallback: (FlTouchEvent event, ScatterTouchResponse? response) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                response == null ||
                response.touchedSpot == null) {
              _touchedIndex = -1;
              return;
            }
            _touchedIndex = response.touchedSpot!.spotIndex;
          });
          
          if (event is FlTapUpEvent && _touchedIndex >= 0) {
            widget.onPointTap?.call(widget.data[_touchedIndex]);
          }
        },
        touchTooltipData: ScatterTouchTooltipData(
          getTooltipColor: (spot) => ReportTheme.primaryColor,
          tooltipBorderRadius: BorderRadius.circular(12),
          getTooltipItems: (spot) {
            final point = widget.data.firstWhere((p) => p.xValue == spot.x && p.yValue == spot.y);
            return ScatterTooltipItem(
              '${point.label}\nCost: ${_formatValue(point.xValue)}\nProfit: ${_formatValue(point.yValue)}',
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      ),
      scatterSpots: widget.data.asMap().entries.map((entry) {
        final index = entry.key;
        final point = entry.value;
        final isTouched = index == _touchedIndex;
        
        Color spotColor;
        if (point.yValue < 0) {
          spotColor = ReportTheme.errorColor;
        } else if (point.yValue / point.xValue > 0.2) {
          spotColor = ReportTheme.successColor;
        } else {
          spotColor = ReportTheme.accentColor;
        }
        
        return ScatterSpot(
          point.xValue,
          point.yValue,
          dotPainter: FlDotCirclePainter(
            radius: isTouched ? 10 : 8,
            color: point.color ?? spotColor,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        );
      }).toList(),
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.scatter_plot, size: 48, color: Colors.grey.shade300),
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
