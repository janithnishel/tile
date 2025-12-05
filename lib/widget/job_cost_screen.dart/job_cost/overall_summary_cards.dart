import 'package:flutter/material.dart';
import 'package:tilework/data/job_cost_mock_data.dart';
import 'package:tilework/utils/job_cost_formatters.dart';
import 'package:tilework/widget/job_cost_screen.dart/summary_card.dart';

class OverallSummaryCards extends StatelessWidget {
  const OverallSummaryCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalProfit = MockData.totalProfit;

    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            icon: Icons.account_balance_wallet,
            title: 'Total Revenue',
            value: AppFormatters.formatCurrency(MockData.totalRevenue),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SummaryCard(
            icon: Icons.shopping_cart,
            title: 'Total Cost',
            value: AppFormatters.formatCurrency(MockData.totalCost),
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
            value: AppFormatters.formatPercentage(MockData.averageMargin),
            color: Colors.purple,
          ),
        ),
      ],
    );
  }
}