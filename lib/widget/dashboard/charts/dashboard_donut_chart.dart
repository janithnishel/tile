// lib/widgets/dashboard/charts/dashboard_donut_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tilework/models/dashboard/dashboard_models.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class DashboardDonutChart extends StatefulWidget {
  final String title;
  final List<ChartSegment> segments;
  final String? centerText;
  final String? centerSubtext;
  final double? height;
  final Function(ChartSegment)? onSegmentTap;

  const DashboardDonutChart({
    Key? key,
    required this.title,
    required this.segments,
    this.centerText,
    this.centerSubtext,
    this.height,
    this.onSegmentTap,
  }) : super(key: key);

  @override
  State<DashboardDonutChart> createState() => _DashboardDonutChartState();
}

class _DashboardDonutChartState extends State<DashboardDonutChart> {
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
                  Icons.pie_chart,
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
          const SizedBox(height: 20),
          SizedBox(
            height: widget.height ?? 200,
            child: widget.segments.isEmpty
                ? _buildEmptyState()
                : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection == null) {
                                        _touchedIndex = -1;
                                        return;
                                      }
                                      _touchedIndex = pieTouchResponse
                                          .touchedSection!.touchedSectionIndex;
                                    });
                                    
                                    if (event is FlTapUpEvent && _touchedIndex >= 0) {
                                      widget.onSegmentTap?.call(widget.segments[_touchedIndex]);
                                    }
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 3,
                                centerSpaceRadius: 50,
                                sections: _buildSections(),
                              ),
                            ),
                            if (widget.centerText != null)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.centerText!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: ReportTheme.textPrimary,
                                    ),
                                  ),
                                  if (widget.centerSubtext != null)
                                    Text(
                                      widget.centerSubtext!,
                                      style: ReportTheme.caption,
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: _buildLegend(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.segments.asMap().entries.map((entry) {
      final isTouched = entry.key == _touchedIndex;
      final segment = entry.value;
      
      return PieChartSectionData(
        color: segment.color,
        value: segment.value,
        title: isTouched ? '${segment.percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 35 : 28,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: segment.color.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  size: 12,
                  color: segment.color,
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.segments.map((segment) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: segment.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${segment.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: ReportTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey.shade300),
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