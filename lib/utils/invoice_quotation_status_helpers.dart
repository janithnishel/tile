import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';

class StatusHelpers {
  // Get status color for filter dropdown
  static Color getFilterStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'partial':
        return Colors.red;
      case 'paid':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'converted':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Get background color for document card
  static Color getDocumentCardColor(QuotationDocument doc) {
    if (doc.type == DocumentType.quotation) {
      if (doc.status == DocumentStatus.approved) return Colors.blue.shade100; // Blue color for approved quotations (ready for conversion)
      return Colors.orange.shade100;
    } else {
      if (doc.status == DocumentStatus.partial ||
          doc.status == DocumentStatus.converted) {
        return Colors.red.shade100;
      }
      if (doc.status == DocumentStatus.paid ||
          doc.status == DocumentStatus.closed) {
        return Colors.green.shade100;
      }
      return Colors.grey.shade100;
    }
  }

  // Get status display text
  static String getStatusDisplayText(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.paid:
        return 'PAID';
      case DocumentStatus.converted:
        return 'CONVERTED';
      default:
        return status.name.toUpperCase();
    }
  }

  // Get document type icon
  static IconData getDocumentTypeIcon(DocumentType type) {
    return type == DocumentType.quotation
        ? Icons.description_outlined
        : Icons.receipt_long;
  }
}
