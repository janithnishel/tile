import 'package:flutter/material.dart';
import 'package:tilework/models/job_cost_screen/other_expense.dart';
import 'package:tilework/utils/job_cost_formatters.dart';

class ExpenseItemRow extends StatelessWidget {
  final OtherExpense expense;

  const ExpenseItemRow({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Category
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                expense.category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.pink.shade700,
                ),
              ),
            ),
          ),
          // Description
          Expanded(
            flex: 3,
            child: Text(expense.description),
          ),
          // Date
          Expanded(
            child: Text(
              AppFormatters.formatShortDate(expense.date),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          // Amount
          Expanded(
            child: Text(
              AppFormatters.formatCurrency(expense.amount),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}