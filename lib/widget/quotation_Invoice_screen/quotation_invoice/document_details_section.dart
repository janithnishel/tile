import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/project_tab_view/date_picker_row.dart';

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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // 💡 වෙනස: Document Number ක්ෂේත්‍රය ඉවත් කර ඇත.
        // දැන් මෙම පේළියේ Invoice/Quotation Date සහ Due Date පමණක් අඩංගු වේ.
        Row(
          children: [
            // 1. Invoice/Quotation Date Field
            Expanded(
              child: DatePickerRow(
                label: document.isQuotation ? 'Quotation Date' : 'Invoice Date',
                date: document.invoiceDate,
                initialDate: document.invoiceDate,
                isEditable: isEditable,
                onDateChanged: onInvoiceDateChanged,
              ),
            ),
            const SizedBox(width: 16),

            // 2. Due Date Field (Previous Due Date Row එක මෙයට ඒකාබද්ධ කර ඇත)
            Expanded(
              child: DatePickerRow(
                label: 'Due Date',
                date: document.dueDate,
                initialDate: document.dueDate,
                isEditable: isEditable,
                onDateChanged: onDueDateChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ❌ _buildDocumentNumberField() method එක සම්පූර්ණයෙන්ම ඉවත් කර ඇත.
}
