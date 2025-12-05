// lib/widgets/dashboard/charts/dashboard_bar_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tilework/models/dashboard/dashboard_models.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class DashboardBarChart extends StatefulWidget {
  final String title;
  final List<ChartDataPoint> data;
  final bool isHorizontal;
  final Color barColor;
  final double? height;
  final Function(ChartDataPoint)? onBarTap;
  final bool showValues;

  const DashboardBarChart({
    Key? key,
    required this.title,
    required this.data,
    this.isHorizontal = true,
    this.barColor = const Color(0xFF7B1FA2),
    this.height,
    this.onBarTap,
    this.showValues = true,
  }) : super(key: key);

  @override
  State<DashboardBarChart> createState() => _DashboardBarChartState();
}

class _DashboardBarChartState extends State<DashboardBarChart> {
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
                  color: widget.barColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: widget.barColor,
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
          const SizedBox(height: 24),
          SizedBox(
            height: widget.height ?? 200,
            child: widget.data.isEmpty
                ? _buildEmptyState()
                : widget.isHorizontal
                    ? _buildHorizontalChart()
                    : _buildVerticalChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalChart() {
    final maxValue = widget.data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        final item = widget.data[index];
        final percentage = item.value / maxValue;
        final isTouched = index == _touchedIndex;
        
        return GestureDetector(
          onTapDown: (_) => setState(() => _touchedIndex = index),
          onTapUp: (_) {
            widget.onBarTap?.call(item);
            setState(() => _touchedIndex = -1);
          },
          onTapCancel: () => setState(() => _touchedIndex = -1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isTouched ? FontWeight.bold : FontWeight.w500,
                      color: ReportTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 24,
                        width: (MediaQuery.of(context).size.width - 200) * percentage,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              item.color ?? widget.barColor,
                              (item.color ?? widget.barColor).withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isTouched
                              ? [
                                  BoxShadow(
                                    color: (item.color ?? widget.barColor).withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.showValues)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      _formatValue(item.value),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: item.color ?? widget.barColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalChart() {
    final maxValue = widget.data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            });

            if (event is FlTapUpEvent && _touchedIndex >= 0) {
              widget.onBarTap?.call(widget.data[_touchedIndex]);
            }
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => ReportTheme.primaryColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${widget.data[groupIndex].label}\n${_formatValue(rod.toY)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      widget.data[index].label,
                      style: TextStyle(
                        fontSize: 10,
                        color: ReportTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              reservedSize: 40,
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
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        barGroups: widget.data.asMap().entries.map((entry) {
          final isTouched = entry.key == _touchedIndex;
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value,
                gradient: LinearGradient(
                  colors: [
                    entry.value.color ?? widget.barColor,
                    (entry.value.color ?? widget.barColor).withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                width: isTouched ? 22 : 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ],
          );
        }).toList(),
      ),
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
          Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade300),
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
