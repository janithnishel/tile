import 'package:flutter/material.dart';
import '../shared/status_badge.dart' as shared;
import '../../utils/job_cost_status_helper.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    Key? key,
    required this.status,
    this.fontSize = 10,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return shared.StatusBadge(
      status: status,
      fontSize: fontSize,
      padding: padding,
      colorGetter: JobCostStatusHelpers.getJobCostStatusColor,
    );
  }
}

class ProfitBadge extends StatelessWidget {
  final double profit;
  final double profitMargin;
  final bool showMargin;

  const ProfitBadge({
    Key? key,
    required this.profit,
    required this.profitMargin,
    this.showMargin = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = profit >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${profitMargin.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color.shade700,
        ),
      ),
    );
  }
}
