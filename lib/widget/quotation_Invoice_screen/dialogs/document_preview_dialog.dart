// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
// import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
// import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';
// import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';
// import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/project_tab_view/info_row.dart';
// import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/project_tab_view/total_row.dart';

// class _GroupedItem {
//   final String description;
//   final double quantity;
//   final double price;
//   final double amount;

//   _GroupedItem({
//     required this.description,
//     required this.quantity,
//     required this.price,
//     required this.amount,
//   });
// }

// class _DeductionItem {
//   final String description;
//   final double amount;

//   _DeductionItem({
//     required this.description,
//     required this.amount,
//   });
// }

// class DocumentPreviewDialog extends StatelessWidget {
//   final QuotationDocument document;
//   final String customerName;
//   final String customerPhone;
//   final String customerAddress;
//   final String projectTitle;

//   const DocumentPreviewDialog({
//     Key? key,
//     required this.document,
//     required this.customerName,
//     required this.customerPhone,
//     required this.customerAddress,
//     required this.projectTitle,
//   }) : super(key: key);

//   String get _title =>
//       document.type == DocumentType.quotation ? 'QUOTATION' : 'INVOICE';

//   Color get _statusColor => document.type == DocumentType.quotation
//       ? Colors.blue.shade700
//       : Colors.red.shade700;

//   // Group line items for display (combine related items like LVT Material + Installation Labor)
//   List<_GroupedItem> _groupLineItems() {
//     final Map<String, List<InvoiceLineItem>> groups = {};

//     // Group items by their base product (remove "Material", "Labor", etc.)
//     for (final item in document.lineItems) {
//       // Skip paid site visits as they are shown as deductions
//       if (item.item.type == ItemType.service &&
//           item.item.name.toLowerCase().contains('site visit') &&
//           item.item.servicePaymentStatus == ServicePaymentStatus.paid) {
//         continue;
//       }

//       final name = item.item.name.toLowerCase();
//       String groupKey = name;

//       // Group related items (e.g., LVT Material and LVT Installation become LVT & Installation)
//       if (name.contains('lvt') || name.contains('tile')) {
//         if (name.contains('material') || name.contains('tile')) {
//           groupKey = name.replaceAll(' material', '').replaceAll(' tile', '');
//         } else if (name.contains('installation') || name.contains('labor')) {
//           groupKey = name.replaceAll(' installation', '').replaceAll(' labor', '');
//         }
//       }

//       if (!groups.containsKey(groupKey)) {
//         groups[groupKey] = [];
//       }
//       groups[groupKey]!.add(item);
//     }

//     final List<_GroupedItem> result = [];

//     for (final entry in groups.entries) {
//       final items = entry.value;
//       final totalAmount = items.fold(0.0, (sum, item) => sum + item.amount);

//       // Create grouped description
//       String description;
//       if (items.length == 1) {
//         final item = items[0];
//         description = '${item.displayName} (${item.item.unit})';
//       } else {
//         // Multiple items in group - create combined description
//         final baseName = entry.key.replaceAll('lvt', 'LVT').replaceAll('tile', 'Tile');
//         final hasMaterial = items.any((item) => item.item.name.toLowerCase().contains('material') || item.item.name.toLowerCase().contains('tile'));
//         final hasLabor = items.any((item) => item.item.name.toLowerCase().contains('installation') || item.item.name.toLowerCase().contains('labor'));

//         if (hasMaterial && hasLabor) {
//           description = '$baseName & Installation';
//         } else {
//           description = items.map((item) => item.displayName).join(' + ');
//         }

//         // Calculate total quantity and average price
//         final totalQuantity = items.fold(0.0, (sum, item) => sum + item.quantity);
//         description += ' (${items[0].item.unit})';
//       }

//       result.add(_GroupedItem(
//         description: description,
//         quantity: items.length == 1 ? items[0].quantity : items.fold(0.0, (sum, item) => sum + item.quantity),
//         price: totalAmount / (items.length == 1 ? items[0].quantity : items.fold(0.0, (sum, item) => sum + item.quantity)),
//         amount: totalAmount,
//       ));
//     }

//     return result;
//   }

//   // Get paid site visit deductions to show separately
//   List<_DeductionItem> _getPaidSiteVisitDeductions() {
//     return document.lineItems
//         .where((item) =>
//             item.item.type == ItemType.service &&
//             item.item.name.toLowerCase().contains('site visit') &&
//             item.item.servicePaymentStatus == ServicePaymentStatus.paid)
//         .map((item) => _DeductionItem(
//               description: item.displayName,
//               amount: item.amount,
//             ))
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('$_title Preview'),
//       content: SingleChildScrollView(
//         child: _buildPreviewContent(),
//       ),
//     );
//   }

//   Widget _buildPreviewContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildHeader(),
//         const Divider(height: 32, thickness: 2),
//         _buildBillToSection(),
//         const SizedBox(height: 32),
//         _buildItemsTable(),
//         const SizedBox(height: 24),
//         _buildTotalSection(),
//         const SizedBox(height: 32),
//         _buildPaymentInstructions(),
//         const SizedBox(height: 32),
//         _buildSignatureSection(),
//       ],
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Flexible(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'IMMENSE HOME PRIVATE LIMITED',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 '157/1 OLD KOTTAWA ROAD, MIRIHANA, NUGEGODA',
//                 style: TextStyle(fontSize: 11),
//               ),
//               Text('Colombo 81300', style: TextStyle(fontSize: 11)),
//               Text(
//                 'Website-www.immensehome.lk | 077 586 70 80',
//                 style: TextStyle(fontSize: 11),
//               ),
//               Text(
//                 'Email: immensehomeprivatelimited@gmail.com',
//                 style: TextStyle(fontSize: 10),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 8),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               _title,
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: _statusColor,
//               ),
//             ),
//             Text(
//               'STATUS: ${document.status.name.toUpperCase()}',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: _statusColor,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildBillToSection() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'BILL TO',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             Text(customerName.isEmpty ? 'N/A' : customerName),
//             if (projectTitle.isNotEmpty)
//               Text(
//                 'Project: $projectTitle',
//                 style: const TextStyle(fontStyle: FontStyle.italic),
//               ),
//             Text(customerPhone.isEmpty ? 'N/A' : customerPhone),
//             Text(customerAddress.isEmpty ? 'N/A' : customerAddress),
//           ],
//         ),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             InfoRowWidget(
//               label: '$_title #',
//               value: document.displayDocumentNumber,
//             ),
//             InfoRowWidget(
//               label: 'Date',
//               value: DateFormat('d MMM yyyy').format(document.invoiceDate),
//             ),
//             InfoRowWidget(
//               label: 'Due Date',
//               value: DateFormat('d MMM yyyy').format(document.dueDate),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildItemsTable() {
//     final groupedItems = _groupLineItems();

//     return Table(
//       border: TableBorder.all(color: Colors.grey.shade400),
//       columnWidths: const {
//         0: FlexColumnWidth(4.5),
//         1: FlexColumnWidth(1.5),
//         2: FlexColumnWidth(2),
//         3: FlexColumnWidth(2),
//       },
//       children: [
//         TableRow(
//           decoration: BoxDecoration(color: Colors.grey.shade200),
//           children: const [
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text('Activity/Item',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child:
//                   Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text('Amount',
//                   textAlign: TextAlign.right,
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//           ],
//         ),
//         ...groupedItems.map((groupedItem) {
//           return TableRow(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(groupedItem.description),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(groupedItem.quantity.toStringAsFixed(1)),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text('Rs ${groupedItem.price.toStringAsFixed(2)}'),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   'Rs ${groupedItem.amount.toStringAsFixed(2)}',
//                   textAlign: TextAlign.right,
//                   style: const TextStyle(fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ],
//           );
//         }),
//         // Add paid site visit deductions as separate rows
//         // Add service items
//         ...document.serviceItems.map((service) {
//           final displayAmount = service.isAlreadyPaid ? -service.amount : service.amount;
//           final amountColor = service.isAlreadyPaid ? Colors.red.shade700 : Colors.black;

//           return TableRow(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text('${service.serviceDescription} (${service.unitTypeDisplay})'),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(service.quantity.toStringAsFixed(1)),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text('Rs ${service.rate.toStringAsFixed(2)}'),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   '${displayAmount >= 0 ? 'Rs' : '-Rs'} ${displayAmount.abs().toStringAsFixed(2)}',
//                   textAlign: TextAlign.right,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: amountColor,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }),

//         // Add paid site visit deductions
//         ..._getPaidSiteVisitDeductions().map((deduction) {
//           return TableRow(
//             decoration: BoxDecoration(color: Colors.red.shade50),
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   '${deduction.description} (Deduction)',
//                   style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text('-'),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text('-'),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   '-Rs ${deduction.amount.toStringAsFixed(2)}',
//                   textAlign: TextAlign.right,
//                   style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade700),
//                 ),
//               ),
//             ],
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildTotalSection() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         SizedBox(
//           width: 300,
//           child: Column(
//             children: [
//               TotalRowWidget(label: 'Subtotal', amount: document.subtotal),
//               TotalRowWidget(
//                   label: 'Total', amount: document.subtotal, isBold: true),
//               if (document.type == DocumentType.invoice &&
//                   document.paymentHistory.isNotEmpty)
//                 ...document.paymentHistory.map(
//                   (p) => TotalRowWidget(
//                     label:
//                         'Paid (${p.description}) on ${DateFormat('d MMM yyyy').format(p.date)}',
//                     amount: -p.amount,
//                     color: Colors.green.shade700,
//                   ),
//                 ),
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   border: Border.all(color: Colors.blue.shade200),
//                 ),
//                 child: document.status == DocumentStatus.paid
//                     ? TotalRowWidget(
//                         label: 'Paid in Full',
//                         amount: 0.0,
//                         isBold: true,
//                         fontSize: 18,
//                         color: Colors.green.shade700,
//                       )
//                     : TotalRowWidget(
//                         label: document.type == DocumentType.quotation
//                             ? 'Estimated Total'
//                             : 'Amount Due',
//                         amount: document.amountDue,
//                         isBold: true,
//                         fontSize: 18,
//                         color: Colors.red.shade700,
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPaymentInstructions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Payment Instruction',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 8),
//         if (document.type == DocumentType.quotation ||
//             (document.type == DocumentType.invoice &&
//                 document.status != DocumentStatus.paid))
//           const Text(
//             '• If you agreed, work commencement will proceed soon after receiving 75% of the quotation amount.',
//             style: TextStyle(fontSize: 13),
//           ),
//         const Text(
//           '• It is essential to pay the amount remaining, after the completion of work.',
//           style: TextStyle(fontSize: 13),
//         ),
//         const Text(
//           '• Please deposit cash/ fund transfer/ cheque payments to the following account.',
//           style: TextStyle(fontSize: 13),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Banking details: Immense home (pvt) Ltd Hatton National Bank, A/C No. 200010008304',
//           style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//         ),
//       ],
//     );
//   }

//   Widget _buildSignatureSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'By signing this document, the customer agrees to the services and conditions described in this document.',
//           style: TextStyle(fontSize: 13),
//         ),
//         const SizedBox(height: 16),
//         const Text('_______________________'),
//         Text(customerName.isEmpty
//             ? 'Customer Signature'
//             : '$customerName (Signature)'),
//       ],
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';

class _GroupedItem {
  final String description;
  final double quantity;
  final double price;
  final double amount;
  final String unit;

  _GroupedItem({
    required this.description,
    required this.quantity,
    required this.price,
    required this.amount,
    this.unit = '',
  });
}

class _DeductionItem {
  final String description;
  final double amount;

  _DeductionItem({
    required this.description,
    required this.amount,
  });
}

class DocumentPreviewDialog extends StatelessWidget {
  final QuotationDocument document;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String projectTitle;

  const DocumentPreviewDialog({
    Key? key,
    required this.document,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.projectTitle,
  }) : super(key: key);

  // Theme colors
  bool get _isQuotation => document.type == DocumentType.quotation;
  
  Color get _primaryColor => _isQuotation 
      ? const Color(0xFF1E88E5) // Blue for quotation
      : const Color(0xFF43A047); // Green for invoice
  
  Color get _primaryLightColor => _isQuotation 
      ? const Color(0xFFE3F2FD) 
      : const Color(0xFFE8F5E9);
  
  Color get _accentColor => const Color(0xFF263238);
  
  String get _title => _isQuotation ? 'QUOTATION' : 'INVOICE';

  String get _statusText {
    switch (document.status) {
      case DocumentStatus.pending:
        return 'PENDING';
      case DocumentStatus.approved:
        return 'APPROVED';
      case DocumentStatus.partial:
        return 'PARTIAL PAID';
      case DocumentStatus.paid:
        return 'PAID';
      case DocumentStatus.converted:
        return 'CONVERTED';
      case DocumentStatus.closed:
        return 'CANCELLED';
      default:
        return document.status.name.toUpperCase();
    }
  }

  Color get _statusColor {
    switch (document.status) {
      case DocumentStatus.pending:
        return Colors.orange;
      case DocumentStatus.approved:
        return Colors.blue;
      case DocumentStatus.partial:
        return Colors.purple;
      case DocumentStatus.paid:
        return Colors.green;
      case DocumentStatus.converted:
        return Colors.teal;
      case DocumentStatus.closed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Group line items for display
  List<_GroupedItem> _groupLineItems() {
    final Map<String, List<InvoiceLineItem>> groups = {};

    for (final item in document.lineItems) {
      if (item.item.type == ItemType.service &&
          item.item.name.toLowerCase().contains('site visit') &&
          item.item.servicePaymentStatus == ServicePaymentStatus.paid) {
        continue;
      }

      final name = item.item.name.toLowerCase();
      String groupKey = name;

      if (name.contains('lvt') || name.contains('tile')) {
        if (name.contains('material') || name.contains('tile')) {
          groupKey = name.replaceAll(' material', '').replaceAll(' tile', '');
        } else if (name.contains('installation') || name.contains('labor')) {
          groupKey = name.replaceAll(' installation', '').replaceAll(' labor', '');
        }
      }

      if (!groups.containsKey(groupKey)) {
        groups[groupKey] = [];
      }
      groups[groupKey]!.add(item);
    }

    final List<_GroupedItem> result = [];

    for (final entry in groups.entries) {
      final items = entry.value;
      final totalAmount = items.fold(0.0, (sum, item) => sum + item.amount);

      String description;
      String unit = items.first.item.unit;
      
      if (items.length == 1) {
        final item = items[0];
        description = item.displayName;
      } else {
        final baseName = entry.key
            .replaceAll('lvt', 'LVT')
            .replaceAll('tile', 'Tile')
            .trim();
        final hasMaterial = items.any((item) => 
            item.item.name.toLowerCase().contains('material') || 
            item.item.name.toLowerCase().contains('tile'));
        final hasLabor = items.any((item) => 
            item.item.name.toLowerCase().contains('installation') || 
            item.item.name.toLowerCase().contains('labor'));

        if (hasMaterial && hasLabor) {
          description = '$baseName & Installation';
        } else {
          description = items.map((item) => item.displayName).join(' + ');
        }
      }

      final totalQty = items.fold(0.0, (sum, item) => sum + item.quantity);

      result.add(_GroupedItem(
        description: description,
        quantity: items.length == 1 ? items[0].quantity : totalQty,
        price: totalAmount / (items.length == 1 ? items[0].quantity : totalQty),
        amount: totalAmount,
        unit: unit,
      ));
    }

    return result;
  }

  List<_DeductionItem> _getPaidSiteVisitDeductions() {
    return document.lineItems
        .where((item) =>
            item.item.type == ItemType.service &&
            item.item.name.toLowerCase().contains('site visit') &&
            item.item.servicePaymentStatus == ServicePaymentStatus.paid)
        .map((item) => _DeductionItem(
              description: item.displayName,
              amount: item.amount,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 900),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildPreviewContent(),
              ),
            ),
            _buildDialogFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isQuotation ? Icons.description_outlined : Icons.receipt_long_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$_title Preview',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildStatusBadge(),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _generateAndSavePDF(context),
            icon: const Icon(Icons.save_alt, color: Colors.white),
            tooltip: 'Save PDF',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _generateAndSavePDF(context),
            icon: const Icon(Icons.download),
            label: const Text('Save PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement print
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompanyHeader(),
          _buildDocumentInfo(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBillToSection(),
                const SizedBox(height: 32),
                _buildItemsTable(),
                const SizedBox(height: 24),
                _buildTotalSection(),
                const SizedBox(height: 32),
                _buildPaymentInstructions(),
                const SizedBox(height: 32),
                _buildTermsAndConditions(),
                const SizedBox(height: 32),
                _buildSignatureSection(),
              ],
            ),
          ),
          _buildFooterWatermark(),
        ],
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryLightColor, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'IH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // Company Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IMMENSE HOME',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _accentColor,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'PRIVATE LIMITED',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _primaryColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildContactRow(Icons.location_on_outlined, 
                    '157/1 Old Kottawa Road, Mirihana, Nugegoda'),
                _buildContactRow(Icons.location_city_outlined, 'Colombo 81300'),
                _buildContactRow(Icons.phone_outlined, '077 586 70 80'),
                _buildContactRow(Icons.language_outlined, 'www.immensehome.lk'),
                _buildContactRow(Icons.email_outlined, 
                    'immensehomeprivatelimited@gmail.com'),
              ],
            ),
          ),
          
          // Document Type Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _statusText,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            icon: Icons.tag,
            label: '$_title No.',
            value: document.displayDocumentNumber,
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.calendar_today,
            label: 'Issue Date',
            value: DateFormat('dd MMM yyyy').format(document.invoiceDate),
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.event,
            label: 'Due Date',
            value: DateFormat('dd MMM yyyy').format(document.dueDate),
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.access_time,
            label: 'Payment Terms',
            value: '${document.paymentTerms} Days',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: _primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: _accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildBillToSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: _primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'BILL TO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _primaryColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  customerName.isEmpty ? 'N/A' : customerName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _accentColor,
                  ),
                ),
                if (projectTitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Project: $projectTitle',
                      style: TextStyle(
                        fontSize: 13,
                        color: _primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (customerPhone.isNotEmpty)
                  _buildCustomerInfoRow(Icons.phone_outlined, customerPhone),
                if (customerAddress.isNotEmpty)
                  _buildCustomerInfoRow(Icons.location_on_outlined, customerAddress),
              ],
            ),
          ),
          
          // QR Code Placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2, size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 4),
                Text(
                  'Scan',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    final groupedItems = _groupLineItems();
    final deductions = _getPaidSiteVisitDeductions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.list_alt,
                color: _primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'ITEMS & SERVICES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: _primaryColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _primaryColor.withOpacity(0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 5,
                        child: Text(
                          'Description',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Qty',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'Rate',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'Amount',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Table Body
                ...List.generate(groupedItems.length, (index) {
                  final item = groupedItems[index];
                  final isEven = index % 2 == 0;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isEven ? Colors.white : Colors.grey.shade50,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: _accentColor,
                                ),
                              ),
                              if (item.unit.isNotEmpty)
                                Text(
                                  'Unit: ${item.unit}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.quantity.toStringAsFixed(1),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Rs ${_formatNumber(item.price)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Rs ${_formatNumber(item.amount)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
                // Service Items
                ...document.serviceItems.map((service) {
                  final displayAmount = service.isAlreadyPaid ? -service.amount : service.amount;
                  final isDeduction = service.isAlreadyPaid;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDeduction ? Colors.red.shade50 : Colors.blue.shade50,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Row(
                            children: [
                              Icon(
                                isDeduction ? Icons.remove_circle_outline : Icons.build_outlined,
                                size: 16,
                                color: isDeduction ? Colors.red.shade700 : Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.serviceDescription,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: isDeduction ? Colors.red.shade700 : _accentColor,
                                      ),
                                    ),
                                    if (isDeduction)
                                      Text(
                                        'Already Paid - Deducted',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.red.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            service.quantity.toStringAsFixed(1),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Rs ${_formatNumber(service.rate)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${displayAmount >= 0 ? '' : '-'}Rs ${_formatNumber(displayAmount.abs())}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDeduction ? Colors.red.shade700 : _accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
                // Deductions
                ...deductions.map((deduction) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border(
                        bottom: BorderSide(color: Colors.red.shade100),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Row(
                            children: [
                              Icon(
                                Icons.remove_circle,
                                size: 16,
                                color: Colors.red.shade600,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '${deduction.description} (Deduction)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Expanded(flex: 2, child: Text('-', textAlign: TextAlign.center)),
                        const Expanded(flex: 2, child: Text('-', textAlign: TextAlign.right)),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '-Rs ${_formatNumber(deduction.amount)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 380,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTotalRow('Subtotal', document.subtotal),

                if (document.type == DocumentType.invoice &&
                    document.paymentHistory.isNotEmpty) ...[
                  const Divider(height: 1),
                  ...document.paymentHistory.map((p) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade100),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade600),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Paid (${p.description})',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd MMM yyyy').format(p.date),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '-Rs ${_formatNumber(p.amount)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // Amount Due / Paid in Full
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: document.status == DocumentStatus.paid
                          ? [Colors.green.shade500, Colors.green.shade600]
                          : [_primaryColor, _primaryColor.withOpacity(0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            document.status == DocumentStatus.paid
                                ? Icons.check_circle
                                : Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            document.status == DocumentStatus.paid
                                ? 'PAID IN FULL'
                                : _isQuotation
                                    ? 'ESTIMATED TOTAL'
                                    : 'AMOUNT DUE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        document.status == DocumentStatus.paid
                            ? 'Rs 0.00'
                            : 'Rs ${_formatNumber(document.amountDue)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {Color? color, IconData? icon}) {
    final isNegative = amount < 0;
    final displayColor = color ?? (isNegative ? Colors.green.shade600 : _accentColor);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: displayColor),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          Text(
            '${isNegative ? '-' : ''}Rs ${_formatNumber(amount.abs())}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: displayColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'PAYMENT INSTRUCTIONS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue.shade700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (document.type == DocumentType.quotation ||
              (document.type == DocumentType.invoice &&
                  document.status != DocumentStatus.paid))
            _buildInstructionItem(
              '1',
              'If you agreed, work commencement will proceed soon after receiving 75% of the quotation amount.',
            ),
          _buildInstructionItem(
            '2',
            'It is essential to pay the amount remaining after the completion of work.',
          ),
          _buildInstructionItem(
            '3',
            'Please deposit cash/fund transfer/cheque payments to the following account.',
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.credit_card, color: Colors.blue.shade700, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bank Details',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Immense Home (Pvt) Ltd',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        'Hatton National Bank',
                        style: TextStyle(fontSize: 13),
                      ),
                      const Text(
                        'A/C No: 200010008304',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: Colors.grey.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'TERMS & CONDITIONS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '• All prices are in Sri Lankan Rupees (LKR)\n'
            '• This quotation is valid for 30 days from the date of issue\n'
            '• Payment terms: 75% advance, balance upon completion\n'
            '• Work will commence within 3-5 business days after advance payment\n'
            '• Any additional work beyond the scope will be charged separately',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'By signing this document, the customer agrees to the services and conditions described above.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Customer Signature
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade400, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          customerName.isEmpty ? 'Customer Signature' : customerName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _accentColor,
                          ),
                        ),
                        Text(
                          'Customer Signature & Date',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  // Company Signature
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade400, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Immense Home (Pvt) Ltd',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _accentColor,
                          ),
                        ),
                        Text(
                          'Authorized Signature',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterWatermark() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: _primaryLightColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_outlined,
            size: 16,
            color: _primaryColor.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Text(
            'This is a computer-generated document. No signature is required.',
            style: TextStyle(
              fontSize: 11,
              color: _primaryColor.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return NumberFormat('#,##0.00').format(number);
    }
    return number.toStringAsFixed(2);
  }

  // PDF Generation Methods
  Future<void> _generateAndSavePDF(BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              _buildPDFHeader(),
              pw.SizedBox(height: 20),
              _buildPDFDocumentInfo(),
              pw.SizedBox(height: 20),
              _buildPDFBillToSection(),
              pw.SizedBox(height: 20),
              _buildPDFItemsTable(),
              pw.SizedBox(height: 20),
              _buildPDFTotalSection(),
              pw.SizedBox(height: 20),
              _buildPDFPaymentInstructions(),
              pw.SizedBox(height: 20),
              _buildPDFTermsAndConditions(),
              pw.SizedBox(height: 20),
              _buildPDFSignatureSection(),
            ];
          },
        ),
      );

      // Generate filename with document number and timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = '${document.documentNumber.replaceAll('/', '_')}_${timestamp}.pdf';

      // Get directory to save PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      // Save PDF file
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Show success message with option to rename
      if (context.mounted) {
        _showFileSavedDialog(context, filePath, fileName);
      }

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFileSavedDialog(BuildContext context, String filePath, String fileName) {
    final TextEditingController fileNameController = TextEditingController(text: fileName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('PDF Saved Successfully'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text('PDF has been saved to your device.'),
              const SizedBox(height: 16),
              TextField(
                controller: fileNameController,
                decoration: const InputDecoration(
                  labelText: 'File Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                OpenFile.open(filePath);
              },
              child: const Text('Open File'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newFileName = fileNameController.text.trim();
                if (newFileName.isNotEmpty && newFileName != fileName) {
                  await _renameFile(filePath, newFileName);
                }
                Navigator.of(context).pop();
                OpenFile.open(newFileName.isNotEmpty ? filePath.replaceAll(fileName, newFileName) : filePath);
              },
              child: const Text('Open & Rename'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameFile(String oldPath, String newFileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/$newFileName';

      final oldFile = File(oldPath);
      await oldFile.rename(newPath);
    } catch (e) {
      // Handle rename error silently
      print('Error renaming file: $e');
    }
  }

  pw.Widget _buildPDFHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [
            _isQuotation ? PdfColors.blue100 : PdfColors.green100,
            PdfColors.white,
          ],
          begin: pw.Alignment.topCenter,
          end: pw.Alignment.bottomCenter,
        ),
        borderRadius: pw.BorderRadius.only(
          topLeft: pw.Radius.circular(8),
          topRight: pw.Radius.circular(8),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Company Logo with shadow effect
          pw.Container(
            width: 80,
            height: 80,
            decoration: pw.BoxDecoration(
              color: _isQuotation ? PdfColors.blue : PdfColors.green,
              borderRadius: pw.BorderRadius.circular(12),
              boxShadow: [
                pw.BoxShadow(
                  color: _isQuotation ? PdfColors.blue : PdfColors.green,
                  blurRadius: 10,
                  offset: PdfPoint(0, 4),
                ),
              ],
            ),
            child: pw.Center(
              child: pw.Text(
                'IH',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 20),

          // Company Details
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'IMMENSE HOME',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                    letterSpacing: 1,
                  ),
                ),
                pw.Text(
                  'PRIVATE LIMITED',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.normal,
                    color: _isQuotation ? PdfColors.blue : PdfColors.green,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 12),
                _buildPDFContactRow('Address', '157/1 Old Kottawa Road, Mirihana, Nugegoda'),
                _buildPDFContactRow('City', 'Colombo 81300'),
                _buildPDFContactRow('Phone', '077 586 70 80'),
                _buildPDFContactRow('Website', 'www.immensehome.lk'),
                _buildPDFContactRow('Email', 'immensehomeprivatelimited@gmail.com'),
              ],
            ),
          ),

          // Document Type Badge with gradient
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: _isQuotation ? PdfColors.blue : PdfColors.green,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  _title,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              // Status Badge
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(20),
                  border: pw.Border.all(color: PdfColors.grey400, width: 1),
                ),
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Container(
                      width: 8,
                      height: 8,
                      decoration: pw.BoxDecoration(
                        color: _getStatusColor(),
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      _statusText,
                      style: pw.TextStyle(
                        color: _getStatusColor(),
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFContactRow(String label, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PdfColor _getStatusColor() {
    switch (document.status) {
      case DocumentStatus.pending:
        return PdfColors.orange;
      case DocumentStatus.approved:
        return PdfColors.blue;
      case DocumentStatus.partial:
        return PdfColors.purple;
      case DocumentStatus.paid:
        return PdfColors.green;
      case DocumentStatus.converted:
        return PdfColors.teal;
      case DocumentStatus.closed:
        return PdfColors.red;
      default:
        return PdfColors.grey;
    }
  }

  PdfColor _getStatusBackgroundColor() {
    switch (document.status) {
      case DocumentStatus.pending:
        return PdfColors.orange100;
      case DocumentStatus.approved:
        return PdfColors.blue100;
      case DocumentStatus.partial:
        return PdfColors.purple100;
      case DocumentStatus.paid:
        return PdfColors.green100;
      case DocumentStatus.converted:
        return PdfColors.teal100;
      case DocumentStatus.closed:
        return PdfColors.red100;
      default:
        return PdfColors.grey100;
    }
  }

  pw.Widget _buildPDFDocumentInfo() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildPDFInfoItem('$_title No.', document.displayDocumentNumber),
          _buildPDFInfoItem('Issue Date', DateFormat('dd MMM yyyy').format(document.invoiceDate)),
          _buildPDFInfoItem('Due Date', DateFormat('dd MMM yyyy').format(document.dueDate)),
          _buildPDFInfoItem('Payment Terms', '${document.paymentTerms} Days'),
        ],
      ),
    );
  }

  pw.Widget _buildPDFInfoItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey600,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPDFBillToSection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BILL TO',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  customerName.isEmpty ? 'N/A' : customerName,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (projectTitle.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Project: $projectTitle',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
                if (customerPhone.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(customerPhone, style: const pw.TextStyle(fontSize: 10)),
                ],
                if (customerAddress.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(customerAddress, style: const pw.TextStyle(fontSize: 10)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFItemsTable() {
    final groupedItems = _groupLineItems();
    final deductions = _getPaidSiteVisitDeductions();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ITEMS & SERVICES',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
          ),
        ),
        pw.SizedBox(height: 8),

        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(5),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.blue100),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Description',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Qty',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Rate',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Amount',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            // Items
            ...groupedItems.map((item) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item.description,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item.quantity.toStringAsFixed(1),
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      'Rs ${_formatNumber(item.price)}',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      'Rs ${_formatNumber(item.amount)}',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }),

            // Service Items
            ...document.serviceItems.map((service) {
              final displayAmount = service.isAlreadyPaid ? -service.amount : service.amount;
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      service.serviceDescription,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      service.quantity.toStringAsFixed(1),
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      'Rs ${_formatNumber(service.rate)}',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      '${displayAmount >= 0 ? 'Rs' : '-Rs'} ${_formatNumber(displayAmount.abs())}',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }),

            // Deductions
            ...deductions.map((deduction) {
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.red50),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      '${deduction.description} (Deduction)',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.red700,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('-', textAlign: pw.TextAlign.center),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('-', textAlign: pw.TextAlign.right),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      '-Rs ${_formatNumber(deduction.amount)}',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red700,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPDFTotalSection() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 250,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            children: [
              _buildPDFTotalRow('Subtotal', document.subtotal),

              if (document.type == DocumentType.invoice &&
                  document.paymentHistory.isNotEmpty) ...[
                pw.Divider(),
                ...document.paymentHistory.map((p) {
                  return _buildPDFTotalRow(
                    'Paid (${p.description}) ${DateFormat('dd MMM yyyy').format(p.date)}',
                    -p.amount,
                  );
                }),
              ],

              // Amount Due / Paid in Full
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: document.status == DocumentStatus.paid
                      ? PdfColors.green200
                      : PdfColors.blue200,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      document.status == DocumentStatus.paid
                          ? 'PAID IN FULL'
                          : _isQuotation
                              ? 'ESTIMATED TOTAL'
                              : 'AMOUNT DUE',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.Text(
                      document.status == DocumentStatus.paid
                          ? 'Rs 0.00'
                          : 'Rs ${_formatNumber(document.amountDue)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPDFTotalRow(String label, double amount) {
    final isNegative = amount < 0;
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '${isNegative ? '-' : ''}Rs ${_formatNumber(amount.abs())}',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFPaymentInstructions() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PAYMENT INSTRUCTIONS',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
            ),
          ),
          pw.SizedBox(height: 8),

          if (document.type == DocumentType.quotation ||
              (document.type == DocumentType.invoice &&
                  document.status != DocumentStatus.paid)) ...[
            pw.Text(
              '• If you agreed, work commencement will proceed soon after receiving 75% of the quotation amount.',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 4),
          ],

          pw.Text(
            '• It is essential to pay the amount remaining after the completion of work.',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '• Please deposit cash/fund transfer/cheque payments to the following account.',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 8),

          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: PdfColors.blue300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Bank Details',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  'Immense Home (Pvt) Ltd',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                pw.Text(
                  'Hatton National Bank',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'A/C No: 200010008304',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    color: PdfColors.blue700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFTermsAndConditions() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TERMS & CONDITIONS',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '• All prices are in Sri Lankan Rupees (LKR)\n'
            '• This quotation is valid for 30 days from the date of issue\n'
            '• Payment terms: 75% advance, balance upon completion\n'
            '• Work will commence within 3-5 business days after advance payment\n'
            '• Any additional work beyond the scope will be charged separately',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
              lineSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFSignatureSection() {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'By signing this document, the customer agrees to the services and conditions described above.',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                children: [
                  // Customer Signature
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          height: 40,
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          customerName.isEmpty ? 'Customer Signature' : customerName,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Customer Signature & Date',
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  // Company Signature
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          height: 40,
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Immense Home (Pvt) Ltd',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Authorized Signature',
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
