import 'package:flutter/material.dart';
import 'package:tilework/models/job_cost_screen/other_expense.dart';

class AddExpenseDialog extends StatefulWidget {
  final Function(OtherExpense) onSave;

  const AddExpenseDialog({
    Key? key,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  static const _categories = ['Labour', 'Transport', 'Tools', 'Miscellaneous'];

  String? _selectedCategory;
  final _descController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.add_circle, color: Colors.teal),
          SizedBox(width: 12),
          Text('Add Other Expense'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rs ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _save() {
    if (_selectedCategory != null &&
        _descController.text.isNotEmpty &&
        _amountController.text.isNotEmpty) {
      final expense = OtherExpense(
        category: _selectedCategory!,
        description: _descController.text,
        amount: double.parse(_amountController.text),
        date: DateTime.now(),
      );
      widget.onSave(expense);
      Navigator.pop(context);
    }
  }
}