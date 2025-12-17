import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerRow extends StatelessWidget {
  final String label;
  final DateTime date;
  final DateTime initialDate;
  final bool isEditable;
  final Function(DateTime) onDateChanged;

  const DatePickerRow({
    Key? key,
    required this.label,
    required this.date,
    required this.initialDate,
    required this.isEditable,
    required this.onDateChanged,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    if (!isEditable) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != date) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEditable ? () => _selectDate(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: !isEditable,
          fillColor: isEditable ? null : Colors.grey.shade100,
          suffixIcon: Icon(
            Icons.calendar_today,
            color: isEditable ? Colors.purple : Colors.grey,
          ),
        ),
        child: Text(
          DateFormat('d MMM yyyy').format(date),
          style: TextStyle(
            color: isEditable ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}