import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_list/project_tab_view/date_picker_row.dart';

class DocumentDetailsSection extends StatelessWidget {
  final QuotationDocument document;
  final bool isEditable;
  final Function(DateTime) onInvoiceDateChanged;
  final Function(DateTime) onDueDateChanged;

  const DocumentDetailsSection({
    Key? key,
    required this.document,
    required this.isEditable,
    required this.onInvoiceDateChanged,
    required this.onDueDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          document.isQuotation ? 'Quotation Details' : 'Invoice Details',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // First Row: Document Number + Date
        Row(
          children: [
            Expanded(
              child: _buildDocumentNumberField(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DatePickerRow(
                label: document.isQuotation ? 'Quotation Date' : 'Invoice Date',
                date: document.invoiceDate,
                initialDate: document.invoiceDate,
                isEditable: isEditable,
                onDateChanged: onInvoiceDateChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Second Row: Due Date
        Row(
          children: [
            Expanded(
              child: DatePickerRow(
                label: 'Due Date',
                date: document.dueDate,
                initialDate: document.dueDate,
                isEditable: isEditable,
                onDateChanged: onDueDateChanged,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentNumberField() {
    return TextField(
      controller: TextEditingController(
        text: document.displayDocumentNumber,
      ),
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Document Number',
        prefixIcon: const Icon(Icons.numbers),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}