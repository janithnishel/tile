import 'package:flutter/material.dart';
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';
import 'package:tilework/widget/job_cost_screen.dart/cost_card.dart';

class CostSummaryRow extends StatelessWidget {
  final JobCostDocument job;

  const CostSummaryRow({
    Key? key,
    required this.job,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CostCard(
            icon: Icons.account_balance_wallet,
            title: 'Total Revenue',
            subtitle: 'From Customer',
            value: job.totalRevenue,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CostCard(
            icon: Icons.inventory,
            title: 'Material Cost',
            subtitle: 'Invoice Items',
            value: job.materialCost,
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CostCard(
            icon: Icons.shopping_cart,
            title: 'PO Cost',
            subtitle: 'From Suppliers',
            value: job.purchaseOrderCost,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CostCard(
            icon: Icons.more_horiz,
            title: 'Other Expenses',
            subtitle: 'Labour, Transport',
            value: job.otherExpensesCost,
            color: Colors.pink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CostCard(
            icon: Icons.trending_up,
            title: 'Net Profit',
            subtitle: '${job.profitMargin.toStringAsFixed(1)}% margin',
            value: job.profit,
            color: job.isProfitable ? Colors.green : Colors.red,
            isHighlighted: true,
          ),
        ),
      ],
    );
  }
}