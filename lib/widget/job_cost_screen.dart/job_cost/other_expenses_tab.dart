import 'package:flutter/material.dart';
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';
import 'package:tilework/utils/job_cost_formatters.dart';
import 'package:tilework/widget/job_cost_screen.dart/data_table_header.dart';
import '../dialogs/add_expense_dialog.dart';
import 'expense_item_row.dart';

class OtherExpensesTab extends StatelessWidget {
  final JobCostDocument job;
  final VoidCallback onDataChanged;

  const OtherExpensesTab({
    Key? key,
    required this.job,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddExpenseDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Expense'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (job.otherExpenses.isEmpty)
            _buildEmptyState()
          else ...[
            // Header
            const DataTableHeader(
              columns: [
                DataTableColumn(label: 'Category'),
                DataTableColumn(label: 'Description', flex: 3),
                DataTableColumn(label: 'Date', alignment: TextAlign.center),
                DataTableColumn(label: 'Amount', alignment: TextAlign.right),
              ],
            ),
            const SizedBox(height: 8),

            // Expenses List
            Expanded(
              child: ListView.builder(
                itemCount: job.otherExpenses.length,
                itemBuilder: (context, index) {
                  return ExpenseItemRow(expense: job.otherExpenses[index]);
                },
              ),
            ),

            // Total
            _buildTotalRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.money_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No other expenses recorded',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 4,
            child: Text('TOTAL OTHER EXPENSES',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              AppFormatters.formatCurrency(job.otherExpensesCost),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddExpenseDialog(
        onSave: (expense) {
          job.addExpense(expense);
          onDataChanged();
        },
      ),
    );
  }
}
