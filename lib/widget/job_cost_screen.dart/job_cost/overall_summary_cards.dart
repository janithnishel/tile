import 'package:flutter/material.dart';
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';
import 'package:tilework/utils/job_cost_formatters.dart';
import 'package:tilework/widget/job_cost_screen.dart/summary_card.dart';

class OverallSummaryCards extends StatelessWidget {
  final List<JobCostDocument> jobCosts;

  const OverallSummaryCards({Key? key, required this.jobCosts}) : super(key: key);

  double get totalRevenue =>
      jobCosts.fold<double>(0, (sum, job) => sum + job.totalRevenue);

  double get totalCost =>
      jobCosts.fold<double>(0, (sum, job) => sum + job.totalCost);

  double get totalProfit => totalRevenue - totalCost;

  double get averageMargin => jobCosts.isNotEmpty
      ? jobCosts.fold<double>(0, (sum, job) => sum + job.profitMargin) /
            jobCosts.length
      : 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            icon: Icons.account_balance_wallet,
            title: 'Total Revenue',
            value: AppFormatters.formatCurrency(totalRevenue),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SummaryCard(
            icon: Icons.shopping_cart,
            title: 'Total Cost',
            value: AppFormatters.formatCurrency(totalCost),
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SummaryCard(
            icon: Icons.trending_up,
            title: 'Total Profit',
            value: AppFormatters.formatCurrency(totalProfit),
            color: totalProfit >= 0 ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SummaryCard(
            icon: Icons.pie_chart,
            title: 'Avg Margin',
            value: AppFormatters.formatPercentage(averageMargin),
            color: Colors.purple,
          ),
        ),
      ],
    );
  }
}
