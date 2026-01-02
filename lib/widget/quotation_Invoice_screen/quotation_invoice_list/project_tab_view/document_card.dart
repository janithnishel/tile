import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';
import 'package:tilework/utils/invoice_quotation_status_helpers.dart';

class DocumentCard extends StatelessWidget {
  final QuotationDocument document;
  final VoidCallback onTap;

  const DocumentCard({
    Key? key,
    required this.document,
    required this.onTap,
  }) : super(key: key);

  String get _detailText {
    if (document.type == DocumentType.invoice &&
        document.amountDue > 0 &&
        document.status != DocumentStatus.paid) {
      return 'Due: Rs ${document.amountDue.toStringAsFixed(2)}';
    } else if (document.type == DocumentType.invoice &&
        document.status == DocumentStatus.paid) {
      return 'Total Paid: Rs ${document.subtotal.toStringAsFixed(2)}';
    } else if (document.type == DocumentType.invoice) {
      return 'Total: Rs ${document.subtotal.toStringAsFixed(2)}';
    } else {
      return 'Estimated Total: Rs ${document.subtotal.toStringAsFixed(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = StatusHelpers.getDocumentCardColor(document);
    final statusDisplay = StatusHelpers.getStatusDisplayText(document.status);
    final icon = document.status == DocumentStatus.rejected
        ? Icons.cancel_outlined
        : StatusHelpers.getDocumentTypeIcon(document.type);

    return Card(
      color: statusColor,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: Icon(icon, color: document.status == DocumentStatus.rejected ? Colors.red.shade800 : Colors.black87),
        title: Text(
          '${document.type.name.toUpperCase()} #${document.documentNumber}'
          '${document.projectTitle.isNotEmpty ? ' - ${document.projectTitle}' : ''}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Status: $statusDisplay | $_detailText'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
