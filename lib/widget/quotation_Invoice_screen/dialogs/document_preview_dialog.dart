// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'package:open_file/open_file.dart';
// import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
// import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
// import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';
// import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';

// class _GroupedItem {
//   final String description;
//   final double quantity;
//   final double price;
//   final double amount;
//   final String unit;

//   _GroupedItem({
//     required this.description,
//     required this.quantity,
//     required this.price,
//     required this.amount,
//     this.unit = '',
//   });
// }

// class _DeductionItem {
//   final String description;
//   final double amount;

//   _DeductionItem({required this.description, required this.amount});
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

//   // Theme colors
//   bool get _isQuotation => document.type == DocumentType.quotation;

//   Color get _primaryColor => _isQuotation
//       ? const Color(0xFF1E88E5) // Blue for quotation
//       : const Color(0xFF43A047); // Green for invoice

//   Color get _primaryLightColor =>
//       _isQuotation ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9);

//   Color get _accentColor => const Color(0xFF263238);

//   String get _title => _isQuotation ? 'QUOTATION' : 'INVOICE';

//   String get _statusText {
//     switch (document.status) {
//       case DocumentStatus.pending:
//         return 'PENDING';
//       case DocumentStatus.approved:
//         return 'APPROVED';
//       case DocumentStatus.partial:
//         return 'PARTIAL PAID';
//       case DocumentStatus.paid:
//         return 'PAID';
//       case DocumentStatus.converted:
//         return 'CONVERTED';
//       case DocumentStatus.closed:
//         return 'CANCELLED';
//       default:
//         return document.status.name.toUpperCase();
//     }
//   }

//   Color get _statusColor {
//     switch (document.status) {
//       case DocumentStatus.pending:
//         return Colors.orange;
//       case DocumentStatus.approved:
//         return Colors.blue;
//       case DocumentStatus.partial:
//         return Colors.purple;
//       case DocumentStatus.paid:
//         return Colors.green;
//       case DocumentStatus.converted:
//         return Colors.teal;
//       case DocumentStatus.closed:
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   // Group line items for display
//   List<_GroupedItem> _groupLineItems() {
//     final Map<String, List<InvoiceLineItem>> groups = {};

//     for (final item in document.lineItems) {
//       if (item.item.type == ItemType.service &&
//           item.item.name.toLowerCase().contains('site visit') &&
//           item.item.servicePaymentStatus == ServicePaymentStatus.paid) {
//         continue;
//       }

//       final name = item.item.name.toLowerCase();
//       String groupKey = name;

//       if (name.contains('lvt') || name.contains('tile')) {
//         if (name.contains('material') || name.contains('tile')) {
//           groupKey = name.replaceAll(' material', '').replaceAll(' tile', '');
//         } else if (name.contains('installation') || name.contains('labor')) {
//           groupKey = name
//               .replaceAll(' installation', '')
//               .replaceAll(' labor', '');
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

//       String description;
//       String unit = items.first.item.unit;

//       if (items.length == 1) {
//         final item = items[0];
//         description = item.displayName;
//       } else {
//         final baseName = entry.key
//             .replaceAll('lvt', 'LVT')
//             .replaceAll('tile', 'Tile')
//             .trim();
//         final hasMaterial = items.any(
//           (item) =>
//               item.item.name.toLowerCase().contains('material') ||
//               item.item.name.toLowerCase().contains('tile'),
//         );
//         final hasLabor = items.any(
//           (item) =>
//               item.item.name.toLowerCase().contains('installation') ||
//               item.item.name.toLowerCase().contains('labor'),
//         );

//         if (hasMaterial && hasLabor) {
//           description = '$baseName & Installation';
//         } else {
//           description = items.map((item) => item.displayName).join(' + ');
//         }
//       }

//       final totalQty = items.fold(0.0, (sum, item) => sum + item.quantity);

//       result.add(
//         _GroupedItem(
//           description: description,
//           quantity: items.length == 1 ? items[0].quantity : totalQty,
//           price:
//               totalAmount / (items.length == 1 ? items[0].quantity : totalQty),
//           amount: totalAmount,
//           unit: unit,
//         ),
//       );
//     }

//     return result;
//   }

//   List<_DeductionItem> _getPaidSiteVisitDeductions() {
//     return document.lineItems
//         .where(
//           (item) =>
//               item.item.type == ItemType.service &&
//               item.item.name.toLowerCase().contains('site visit') &&
//               item.item.servicePaymentStatus == ServicePaymentStatus.paid,
//         )
//         .map(
//           (item) => _DeductionItem(
//             description: item.displayName,
//             amount: item.amount,
//           ),
//         )
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.all(16),
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 800, maxHeight: 900),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildDialogHeader(context),
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24),
//                 child: _buildPreviewContent(),
//               ),
//             ),
//             _buildDialogFooter(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDialogHeader(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               _isQuotation
//                   ? Icons.description_outlined
//                   : Icons.receipt_long_outlined,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             '$_title Preview',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const Spacer(),
//           _buildStatusBadge(),
//           const SizedBox(width: 12),
//           IconButton(
//             onPressed: () => _generateAndSavePDF(context),
//             icon: const Icon(Icons.save_alt, color: Colors.white),
//             tooltip: 'Save PDF',
//             style: IconButton.styleFrom(
//               backgroundColor: Colors.white.withOpacity(0.2),
//             ),
//           ),
//           const SizedBox(width: 8),
//           IconButton(
//             onPressed: () => Navigator.of(context).pop(),
//             icon: const Icon(Icons.close, color: Colors.white),
//             style: IconButton.styleFrom(
//               backgroundColor: Colors.white.withOpacity(0.2),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: _statusColor.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.5)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 4),
//               ],
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             _statusText,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDialogFooter(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(16),
//           bottomRight: Radius.circular(16),
//         ),
//         border: Border(top: BorderSide(color: Colors.grey.shade200)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           OutlinedButton.icon(
//             onPressed: () => Navigator.of(context).pop(),
//             icon: const Icon(Icons.close),
//             label: const Text('Close'),
//             style: OutlinedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           ElevatedButton.icon(
//             onPressed: () => _generateAndSavePDF(context),
//             icon: const Icon(Icons.download),
//             label: const Text('Save PDF'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _primaryColor,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           ElevatedButton.icon(
//             onPressed: () => _printPDF(context),
//             icon: const Icon(Icons.print),
//             label: const Text('Print'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _accentColor,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPreviewContent() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: Colors.grey.shade200),
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildCompanyHeader(),
//           _buildDocumentInfo(),
//           Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildBillToSection(),
//                 const SizedBox(height: 32),
//                 _buildItemsTable(),
//                 const SizedBox(height: 24),
//                 _buildTotalSection(),
//                 const SizedBox(height: 32),
//                 _buildPaymentInstructions(),
//                 const SizedBox(height: 32),
//                 _buildTermsAndConditions(),
//                 const SizedBox(height: 32),
//                 _buildSignatureSection(),
//               ],
//             ),
//           ),
//           _buildFooterWatermark(),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompanyHeader() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [_primaryLightColor, Colors.white],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(8),
//           topRight: Radius.circular(8),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Company Logo
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: _primaryColor,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: _primaryColor.withOpacity(0.3),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: const Center(
//               child: Text(
//                 'IH',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 20),

//           // Company Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'IMMENSE HOME',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: _accentColor,
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 Text(
//                   'PRIVATE LIMITED',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: _primaryColor,
//                     letterSpacing: 2,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 _buildContactRow(
//                   Icons.location_on_outlined,
//                   '157/1 Old Kottawa Road, Mirihana, Nugegoda',
//                 ),
//                 _buildContactRow(Icons.location_city_outlined, 'Colombo 81300'),
//                 _buildContactRow(Icons.phone_outlined, '077 586 70 80'),
//                 _buildContactRow(Icons.language_outlined, 'www.immensehome.lk'),
//                 _buildContactRow(
//                   Icons.email_outlined,
//                   'immensehomeprivatelimited@gmail.com',
//                 ),
//               ],
//             ),
//           ),

//           // Document Type Badge
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: _primaryColor.withOpacity(0.3),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Text(
//                   _title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 2,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _statusColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: _statusColor.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color: _statusColor,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       _statusText,
//                       style: TextStyle(
//                         color: _statusColor,
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContactRow(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         children: [
//           Icon(icon, size: 14, color: Colors.grey.shade600),
//           const SizedBox(width: 8),
//           Flexible(
//             child: Text(
//               text,
//               style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDocumentInfo() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         border: Border(
//           top: BorderSide(color: Colors.grey.shade200),
//           bottom: BorderSide(color: Colors.grey.shade200),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildInfoItem(
//             icon: Icons.tag,
//             label: '$_title No.',
//             value: document.displayDocumentNumber,
//           ),
//           _buildDivider(),
//           _buildInfoItem(
//             icon: Icons.calendar_today,
//             label: 'Issue Date',
//             value: DateFormat('dd MMM yyyy').format(document.invoiceDate),
//           ),
//           _buildDivider(),
//           _buildInfoItem(
//             icon: Icons.event,
//             label: 'Due Date',
//             value: DateFormat('dd MMM yyyy').format(document.dueDate),
//           ),
//           _buildDivider(),
//           _buildInfoItem(
//             icon: Icons.access_time,
//             label: 'Payment Terms',
//             value: '${document.paymentTerms} Days',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoItem({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, size: 20, color: _primaryColor),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 11,
//             color: Colors.grey.shade600,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 14,
//             color: _accentColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDivider() {
//     return Container(height: 40, width: 1, color: Colors.grey.shade300);
//   }

//   Widget _buildBillToSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: _primaryColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         Icons.person_outline,
//                         color: _primaryColor,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'BILL TO',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                         color: _primaryColor,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   customerName.isEmpty ? 'N/A' : customerName,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: _accentColor,
//                   ),
//                 ),
//                 if (projectTitle.isNotEmpty) ...[
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _primaryColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       'Project: $projectTitle',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: _primaryColor,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//                 const SizedBox(height: 12),
//                 if (customerPhone.isNotEmpty)
//                   _buildCustomerInfoRow(Icons.phone_outlined, customerPhone),
//                 if (customerAddress.isNotEmpty)
//                   _buildCustomerInfoRow(
//                     Icons.location_on_outlined,
//                     customerAddress,
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCustomerInfoRow(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: Colors.grey.shade500),
//           const SizedBox(width: 8),
//           Flexible(
//             child: Text(
//               text,
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildItemsTable() {
//     final groupedItems = _groupLineItems();
//     final deductions = _getPaidSiteVisitDeductions();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: _primaryColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(Icons.list_alt, color: _primaryColor, size: 20),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'ITEMS & SERVICES',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14,
//                 color: _primaryColor,
//                 letterSpacing: 1,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),

//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade200),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Column(
//               children: [
//                 // Table Header
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 14,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [_primaryColor, _primaryColor.withOpacity(0.85)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       const Expanded(
//                         flex: 5,
//                         child: Text(
//                           'Description',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: Text(
//                           'Qty',
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                       const Expanded(
//                         flex: 2,
//                         child: Text(
//                           'Rate',
//                           textAlign: TextAlign.right,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                       const Expanded(
//                         flex: 2,
//                         child: Text(
//                           'Amount',
//                           textAlign: TextAlign.right,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Table Body
//                 ...List.generate(groupedItems.length, (index) {
//                   final item = groupedItems[index];
//                   final isEven = index % 2 == 0;

//                   return Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 14,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isEven ? Colors.white : Colors.grey.shade50,
//                       border: Border(
//                         bottom: BorderSide(color: Colors.grey.shade100),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 5,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 item.description,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 13,
//                                   color: _accentColor,
//                                 ),
//                               ),
//                               if (item.unit.isNotEmpty)
//                                 Text(
//                                   'Unit: ${item.unit}',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: Colors.grey.shade500,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             item.quantity.toStringAsFixed(1),
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(fontSize: 13),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             'Rs ${_formatNumber(item.price)}',
//                             textAlign: TextAlign.right,
//                             style: const TextStyle(fontSize: 13),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             'Rs ${_formatNumber(item.amount)}',
//                             textAlign: TextAlign.right,
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: _accentColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),

//                 // Service Items
//                 ...document.serviceItems.map((service) {
//                   final displayAmount = service.isAlreadyPaid
//                       ? -service.amount
//                       : service.amount;
//                   final isDeduction = service.isAlreadyPaid;

//                   return Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 14,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isDeduction
//                           ? Colors.red.shade50
//                           : Colors.blue.shade50,
//                       border: Border(
//                         bottom: BorderSide(color: Colors.grey.shade100),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 5,
//                           child: Row(
//                             children: [
//                               Icon(
//                                 isDeduction
//                                     ? Icons.remove_circle_outline
//                                     : Icons.build_outlined,
//                                 size: 16,
//                                 color: isDeduction
//                                     ? Colors.red.shade700
//                                     : Colors.blue.shade700,
//                               ),
//                               const SizedBox(width: 8),
//                               Flexible(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       service.serviceDescription,
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 13,
//                                         color: isDeduction
//                                             ? Colors.red.shade700
//                                             : _accentColor,
//                                       ),
//                                     ),
//                                     if (isDeduction)
//                                       Text(
//                                         'Already Paid - Deducted',
//                                         style: TextStyle(
//                                           fontSize: 11,
//                                           color: Colors.red.shade600,
//                                           fontStyle: FontStyle.italic,
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             service.quantity.toStringAsFixed(1),
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(fontSize: 13),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             'Rs ${_formatNumber(service.rate)}',
//                             textAlign: TextAlign.right,
//                             style: const TextStyle(fontSize: 13),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             '${displayAmount >= 0 ? '' : '-'}Rs ${_formatNumber(displayAmount.abs())}',
//                             textAlign: TextAlign.right,
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: isDeduction
//                                   ? Colors.red.shade700
//                                   : _accentColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),

//                 // Deductions
//                 ...deductions.map((deduction) {
//                   return Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 14,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       border: Border(
//                         bottom: BorderSide(color: Colors.red.shade100),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 5,
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.remove_circle,
//                                 size: 16,
//                                 color: Colors.red.shade600,
//                               ),
//                               const SizedBox(width: 8),
//                               Flexible(
//                                 child: Text(
//                                   '${deduction.description} (Deduction)',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 13,
//                                     color: Colors.red.shade700,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Expanded(
//                           flex: 2,
//                           child: Text('-', textAlign: TextAlign.center),
//                         ),
//                         const Expanded(
//                           flex: 2,
//                           child: Text('-', textAlign: TextAlign.right),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             '-Rs ${_formatNumber(deduction.amount)}',
//                             textAlign: TextAlign.right,
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red.shade700,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTotalSection() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Container(
//             width: 380,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey.shade200),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 _buildTotalRow('Subtotal', document.subtotal),

//                 if (document.type == DocumentType.invoice &&
//                     document.paymentHistory.isNotEmpty) ...[
//                   const Divider(height: 1),
//                   ...document.paymentHistory.map((p) {
//                     return Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border(
//                           bottom: BorderSide(color: Colors.grey.shade100),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       Icons.check_circle_outline,
//                                       size: 16,
//                                       color: Colors.green.shade600,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             'Paid (${p.description})',
//                                             style: TextStyle(
//                                               fontSize: 13,
//                                               color: Colors.grey.shade700,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                           Text(
//                                             DateFormat(
//                                               'dd MMM yyyy',
//                                             ).format(p.date),
//                                             style: TextStyle(
//                                               fontSize: 11,
//                                               color: Colors.grey.shade500,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Text(
//                                 '-Rs ${_formatNumber(p.amount)}',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.green.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ],

//                 // Amount Due / Paid in Full
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: document.status == DocumentStatus.paid
//                           ? [Colors.green.shade500, Colors.green.shade600]
//                           : [_primaryColor, _primaryColor.withOpacity(0.85)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(11),
//                       bottomRight: Radius.circular(11),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             document.status == DocumentStatus.paid
//                                 ? Icons.check_circle
//                                 : Icons.account_balance_wallet,
//                             color: Colors.white,
//                             size: 22,
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             document.status == DocumentStatus.paid
//                                 ? 'PAID IN FULL'
//                                 : _isQuotation
//                                 ? 'ESTIMATED TOTAL'
//                                 : 'AMOUNT DUE',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         document.status == DocumentStatus.paid
//                             ? 'Rs 0.00'
//                             : 'Rs ${_formatNumber(document.amountDue)}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTotalRow(
//     String label,
//     double amount, {
//     Color? color,
//     IconData? icon,
//   }) {
//     final isNegative = amount < 0;
//     final displayColor =
//         color ?? (isNegative ? Colors.green.shade600 : _accentColor);

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               if (icon != null) ...[
//                 Icon(icon, size: 16, color: displayColor),
//                 const SizedBox(width: 8),
//               ],
//               Text(
//                 label,
//                 style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
//               ),
//             ],
//           ),
//           Text(
//             '${isNegative ? '-' : ''}Rs ${_formatNumber(amount.abs())}',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: displayColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaymentInstructions() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue.shade100),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade100,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.account_balance,
//                   color: Colors.blue.shade700,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'PAYMENT INSTRUCTIONS',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                   color: Colors.blue.shade700,
//                   letterSpacing: 1,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           if (document.type == DocumentType.quotation ||
//               (document.type == DocumentType.invoice &&
//                   document.status != DocumentStatus.paid))
//             _buildInstructionItem(
//               '1',
//               'If you agreed, work commencement will proceed soon after receiving 75% of the quotation amount.',
//             ),
//           _buildInstructionItem(
//             '2',
//             'It is essential to pay the amount remaining after the completion of work.',
//           ),
//           _buildInstructionItem(
//             '3',
//             'Please deposit cash/fund transfer/cheque payments to the following account.',
//           ),

//           const SizedBox(height: 16),

//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.blue.shade200),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.credit_card, color: Colors.blue.shade700, size: 32),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Bank Details',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       const Text(
//                         'Immense Home (Pvt) Ltd',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const Text(
//                         'Hatton National Bank',
//                         style: TextStyle(fontSize: 13),
//                       ),
//                       const Text(
//                         'A/C No: 200010008304',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInstructionItem(String number, String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 22,
//             height: 22,
//             decoration: BoxDecoration(
//               color: Colors.blue.shade700,
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 number,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey.shade700,
//                 height: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTermsAndConditions() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.description_outlined,
//                   color: Colors.grey.shade700,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'TERMS & CONDITIONS',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                   color: Colors.grey.shade700,
//                   letterSpacing: 1,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             '• All prices are in Sri Lankan Rupees (LKR)\n'
//             '• This quotation is valid for 30 days from the date of issue\n'
//             '• Payment terms: 75% advance, balance upon completion\n'
//             '• Work will commence within 3-5 business days after advance payment\n'
//             '• Any additional work beyond the scope will be charged separately',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//               height: 1.6,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSignatureSection() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'By signing this document, the customer agrees to the services and conditions described above.',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade600,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   // Customer Signature
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           height: 60,
//                           decoration: BoxDecoration(
//                             border: Border(
//                               bottom: BorderSide(
//                                 color: Colors.grey.shade400,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           customerName.isEmpty
//                               ? 'Customer Signature'
//                               : customerName,
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             color: _accentColor,
//                           ),
//                         ),
//                         Text(
//                           'Customer Signature & Date',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey.shade500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 40),
//                   // Company Signature
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           height: 60,
//                           decoration: BoxDecoration(
//                             border: Border(
//                               bottom: BorderSide(
//                                 color: Colors.grey.shade400,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Immense Home (Pvt) Ltd',
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             color: _accentColor,
//                           ),
//                         ),
//                         Text(
//                           'Authorized Signature',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey.shade500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFooterWatermark() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//       decoration: BoxDecoration(
//         color: _primaryLightColor,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(8),
//           bottomRight: Radius.circular(8),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.verified_outlined,
//             size: 16,
//             color: _primaryColor.withOpacity(0.7),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             'This is a computer-generated document. No signature is required.',
//             style: TextStyle(
//               fontSize: 11,
//               color: _primaryColor.withOpacity(0.7),
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatNumber(double number) {
//     if (number >= 1000) {
//       return NumberFormat('#,##0.00').format(number);
//     }
//     return number.toStringAsFixed(2);
//   }

//   // PDF Generation Methods - Exact UI Mirror with Fixed Colors & Icons
//   Future<void> _generateAndSavePDF(BuildContext context) async {
//     // Load fonts explicitly for consistent typography
//     final regularFont = await PdfGoogleFonts.robotoRegular();
//     final boldFont = await PdfGoogleFonts.robotoBold();

//     final pdf = pw.Document();
//     final groupedItems = _groupLineItems();
//     final deductions = _getPaidSiteVisitDeductions();

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(24),
//         theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
//         build: (pw.Context context) {
//           return [
//             // === HEADER - Exact UI Match ===
//             pw.Container(
//               padding: const pw.EdgeInsets.all(24),
//               decoration: pw.BoxDecoration(
//                 gradient: pw.LinearGradient(
//                   colors: [
//                     PdfColor.fromInt(
//                       _isQuotation ? 0xFF1E88E5 : 0xFF43A047,
//                     ), // Exact primary color from UI
//                     PdfColor.fromInt(
//                       _isQuotation ? 0xFF1565C0 : 0xFF2E7D32,
//                     ), // Darker shade like UI
//                   ],
//                   begin: pw.Alignment.topLeft,
//                   end: pw.Alignment.bottomRight,
//                 ),
//                 borderRadius: pw.BorderRadius.only(
//                   topLeft: pw.Radius.circular(16),
//                   topRight: pw.Radius.circular(16),
//                 ),
//               ),
//               child: pw.Row(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   // Company Logo
//                   pw.Container(
//                     width: 80,
//                     height: 80,
//                     decoration: pw.BoxDecoration(
//                       color: PdfColor.fromInt(0xFF43A047),
//                       borderRadius: pw.BorderRadius.circular(12),
//                     ),
//                     child: pw.Center(
//                       child: pw.Text(
//                         'IH',
//                         style: pw.TextStyle(
//                           color: PdfColors.white,
//                           fontSize: 28,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   pw.SizedBox(width: 20),

//                   // Company Details
//                   pw.Expanded(
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text(
//                           'IMMENSE HOME',
//                           style: pw.TextStyle(
//                             fontSize: 24,
//                             fontWeight: pw.FontWeight.bold,
//                             color: PdfColors.white,
//                             letterSpacing: 1,
//                           ),
//                         ),
//                         pw.Text(
//                           'PRIVATE LIMITED',
//                           style: pw.TextStyle(
//                             fontSize: 14,
//                             fontWeight: pw.FontWeight.normal,
//                             color: PdfColors.white,
//                             letterSpacing: 2,
//                           ),
//                         ),
//                         pw.SizedBox(height: 12),
//                         // Use clear text symbols instead of emojis
//                         _buildPDFContactRow(
//                           '•',
//                           '157/1 Old Kottawa Road, Mirihana, Nugegoda',
//                         ),
//                         _buildPDFContactRow('•', 'Colombo 81300'),
//                         _buildPDFContactRow('•', '077 586 70 80'),
//                         _buildPDFContactRow('•', 'www.immensehome.lk'),
//                         _buildPDFContactRow(
//                           '•',
//                           'immensehomeprivatelimited@gmail.com',
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Document Type Badge
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.end,
//                     children: [
//                       pw.Container(
//                         padding: const pw.EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 12,
//                         ),
//                         decoration: pw.BoxDecoration(
//                           gradient: pw.LinearGradient(
//                             colors: [
//                               PdfColor.fromInt(0xFF43A047),
//                               PdfColor(0.4, 0.8, 0.4, 1.0),
//                             ],
//                             begin: pw.Alignment.topLeft,
//                             end: pw.Alignment.bottomRight,
//                           ),
//                           borderRadius: pw.BorderRadius.circular(8),
//                         ),
//                         child: pw.Text(
//                           _title,
//                           style: pw.TextStyle(
//                             color: PdfColors.white,
//                             fontSize: 22,
//                             fontWeight: pw.FontWeight.bold,
//                             letterSpacing: 2,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // === DOCUMENT INFO BAR ===
//             pw.Container(
//               padding: const pw.EdgeInsets.symmetric(
//                 horizontal: 24,
//                 vertical: 16,
//               ),
//               decoration: pw.BoxDecoration(
//                 color: PdfColor.fromInt(0xFFF5F5F5), // Colors.grey.shade50
//                 border: pw.Border(
//                   top: pw.BorderSide(color: PdfColor.fromInt(0xFFE0E0E0)),
//                   bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE0E0E0)),
//                 ),
//               ),
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildPDFInfoItem(
//                     '$_title No.',
//                     document.displayDocumentNumber,
//                   ),
//                   _buildPDFDivider(),
//                   _buildPDFInfoItem(
//                     'Issue Date',
//                     DateFormat('dd MMM yyyy').format(document.invoiceDate),
//                   ),
//                   _buildPDFDivider(),
//                   _buildPDFInfoItem(
//                     'Due Date',
//                     DateFormat('dd MMM yyyy').format(document.dueDate),
//                   ),
//                   _buildPDFDivider(),
//                   _buildPDFInfoItem(
//                     'Payment Terms',
//                     '${document.paymentTerms} Days',
//                   ),
//                 ],
//               ),
//             ),

//             // === MAIN CONTENT ===
//             pw.Padding(
//               padding: const pw.EdgeInsets.all(24),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   // BILL TO SECTION
//                   pw.Container(
//                     padding: const pw.EdgeInsets.all(20),
//                     decoration: pw.BoxDecoration(
//                       color: PdfColor.fromInt(
//                         0xFFF5F5F5,
//                       ), // Colors.grey.shade50
//                       borderRadius: pw.BorderRadius.circular(12),
//                       border: pw.Border.all(
//                         color: PdfColor.fromInt(0xFFE0E0E0),
//                       ), // Colors.grey.shade200
//                     ),
//                     child: pw.Row(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Expanded(
//                           child: pw.Column(
//                             crossAxisAlignment: pw.CrossAxisAlignment.start,
//                             children: [
//                               // BILL TO Header
//                               pw.Row(
//                                 children: [
//                                   pw.Container(
//                                     padding: const pw.EdgeInsets.all(8),
//                                     decoration: pw.BoxDecoration(
//                                       color: PdfColor.fromInt(0x1A43A047),
//                                       borderRadius: pw.BorderRadius.circular(8),
//                                     ),
//                                     child: pw.Text(
//                                       'PERSON',
//                                       style: pw.TextStyle(
//                                         fontSize: 10,
//                                         color: PdfColor.fromInt(0xFF43A047),
//                                         fontWeight: pw.FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   pw.SizedBox(width: 12),
//                                   pw.Text(
//                                     'BILL TO',
//                                     style: pw.TextStyle(
//                                       fontWeight: pw.FontWeight.bold,
//                                       fontSize: 14,
//                                       color: PdfColor.fromInt(0xFF43A047),
//                                       letterSpacing: 1,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               pw.SizedBox(height: 16),
//                               pw.Text(
//                                 customerName.isEmpty ? 'N/A' : customerName,
//                                 style: pw.TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: pw.FontWeight.bold,
//                                   color: PdfColors.black,
//                                 ),
//                               ),
//                               if (projectTitle.isNotEmpty) ...[
//                                 pw.SizedBox(height: 8),
//                                 pw.Container(
//                                   padding: const pw.EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                     vertical: 4,
//                                   ),
//                                   decoration: pw.BoxDecoration(
//                                     color: PdfColor.fromInt(0x1A43A047),
//                                     borderRadius: pw.BorderRadius.circular(4),
//                                   ),
//                                   child: pw.Text(
//                                     'Project: $projectTitle',
//                                     style: pw.TextStyle(
//                                       fontSize: 13,
//                                       color: PdfColor.fromInt(0xFF43A047),
//                                       fontWeight: pw.FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                               pw.SizedBox(height: 12),
//                               if (customerPhone.isNotEmpty)
//                                 _buildPDFCustomerInfoRow('TEL', customerPhone),
//                               if (customerAddress.isNotEmpty)
//                                 _buildPDFCustomerInfoRow(
//                                   'LOC',
//                                   customerAddress,
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   pw.SizedBox(height: 32),

//                   // ITEMS & SERVICES TABLE
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       // Header
//                       pw.Row(
//                         children: [
//                           pw.Container(
//                             padding: const pw.EdgeInsets.all(8),
//                             decoration: pw.BoxDecoration(
//                               color: PdfColor.fromInt(0x1A43A047),
//                               borderRadius: pw.BorderRadius.circular(8),
//                             ),
//                             child: pw.Text(
//                               'LIST',
//                               style: pw.TextStyle(
//                                 fontSize: 10,
//                                 color: PdfColor.fromInt(0xFF43A047),
//                                 fontWeight: pw.FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           pw.SizedBox(width: 12),
//                           pw.Text(
//                             'ITEMS & SERVICES',
//                             style: pw.TextStyle(
//                               fontWeight: pw.FontWeight.bold,
//                               fontSize: 14,
//                               color: PdfColor.fromInt(0xFF43A047),
//                               letterSpacing: 1,
//                             ),
//                           ),
//                         ],
//                       ),
//                       pw.SizedBox(height: 16),

//                       // Table Container
//                       pw.Container(
//                         decoration: pw.BoxDecoration(
//                           borderRadius: pw.BorderRadius.circular(12),
//                           border: pw.Border.all(
//                             color: PdfColor.fromInt(0xFFE0E0E0),
//                           ),
//                         ),
//                         child: pw.Column(
//                           children: [
//                             // Table Header - Solid green background
//                             pw.Container(
//                               padding: const pw.EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 14,
//                               ),
//                               decoration: pw.BoxDecoration(
//                                 gradient: pw.LinearGradient(
//                                   colors: [
//                                     PdfColor.fromInt(0xFF43A047),
//                                     PdfColor(0.4, 0.8, 0.4, 1.0),
//                                   ],
//                                   begin: pw.Alignment.topLeft,
//                                   end: pw.Alignment.bottomRight,
//                                 ),
//                               ),
//                               child: pw.Row(
//                                 children: [
//                                   pw.Expanded(
//                                     flex: 5,
//                                     child: pw.Text(
//                                       'Description',
//                                       style: pw.TextStyle(
//                                         color: PdfColors.white,
//                                         fontWeight: pw.FontWeight.bold,
//                                         fontSize: 13,
//                                       ),
//                                     ),
//                                   ),
//                                   pw.Expanded(
//                                     flex: 2,
//                                     child: pw.Text(
//                                       'Qty',
//                                       textAlign: pw.TextAlign.center,
//                                       style: pw.TextStyle(
//                                         color: PdfColors.white,
//                                         fontWeight: pw.FontWeight.bold,
//                                         fontSize: 13,
//                                       ),
//                                     ),
//                                   ),
//                                   pw.Expanded(
//                                     flex: 2,
//                                     child: pw.Text(
//                                       'Rate',
//                                       textAlign: pw.TextAlign.right,
//                                       style: pw.TextStyle(
//                                         color: PdfColors.white,
//                                         fontWeight: pw.FontWeight.bold,
//                                         fontSize: 13,
//                                       ),
//                                     ),
//                                   ),
//                                   pw.Expanded(
//                                     flex: 2,
//                                     child: pw.Text(
//                                       'Amount',
//                                       textAlign: pw.TextAlign.right,
//                                       style: pw.TextStyle(
//                                         color: PdfColors.white,
//                                         fontWeight: pw.FontWeight.bold,
//                                         fontSize: 13,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // Table Body - Alternating rows
//                             ...List.generate(groupedItems.length, (index) {
//                               final item = groupedItems[index];
//                               final isEven = index % 2 == 0;

//                               return pw.Container(
//                                 padding: const pw.EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 14,
//                                 ),
//                                 decoration: pw.BoxDecoration(
//                                   color: isEven
//                                       ? PdfColors.white
//                                       : PdfColor.fromInt(0xFFF5F5F5),
//                                   border: pw.Border(
//                                     bottom: pw.BorderSide(
//                                       color: PdfColor.fromInt(0xFFEEEEEE),
//                                     ),
//                                   ),
//                                 ),
//                                 child: pw.Row(
//                                   children: [
//                                     pw.Expanded(
//                                       flex: 5,
//                                       child: pw.Column(
//                                         crossAxisAlignment:
//                                             pw.CrossAxisAlignment.start,
//                                         children: [
//                                           pw.Text(
//                                             item.description,
//                                             style: pw.TextStyle(
//                                               fontWeight: pw.FontWeight.bold,
//                                               fontSize: 13,
//                                               color: PdfColors.black,
//                                             ),
//                                           ),
//                                           if (item.unit.isNotEmpty)
//                                             pw.Text(
//                                               'Unit: ${item.unit}',
//                                               style: pw.TextStyle(
//                                                 fontSize: 11,
//                                                 color: PdfColor.fromInt(
//                                                   0xFF9E9E9E,
//                                                 ),
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                     pw.Expanded(
//                                       flex: 2,
//                                       child: pw.Text(
//                                         item.quantity.toStringAsFixed(1),
//                                         textAlign: pw.TextAlign.center,
//                                         style: const pw.TextStyle(fontSize: 13),
//                                       ),
//                                     ),
//                                     pw.Expanded(
//                                       flex: 2,
//                                       child: pw.Text(
//                                         'Rs ${_formatNumber(item.price)}',
//                                         textAlign: pw.TextAlign.right,
//                                         style: const pw.TextStyle(fontSize: 13),
//                                       ),
//                                     ),
//                                     pw.Expanded(
//                                       flex: 2,
//                                       child: pw.Text(
//                                         'Rs ${_formatNumber(item.amount)}',
//                                         textAlign: pw.TextAlign.right,
//                                         style: pw.TextStyle(
//                                           fontSize: 13,
//                                           fontWeight: pw.FontWeight.bold,
//                                           color: PdfColors.black,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }),

//                             // Service Items
//                             ...document.serviceItems.map((service) {
//                               final displayAmount = service.isAlreadyPaid
//                                   ? -service.amount
//                                   : service.amount;
//                               final isDeduction = service.isAlreadyPaid;

//                               return pw.Container(
//                                 padding: const pw.EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 14,
//                                 ),
//                                 decoration: pw.BoxDecoration(
//                                   color: isDeduction
//                                       ? PdfColor.fromInt(
//                                           0xFFFFEBEE,
//                                         ) // Colors.red.shade50
//                                       : PdfColor.fromInt(
//                                           0xFFE3F2FD,
//                                         ), // Colors.blue.shade50
//                                   border: pw.Border(
//                                     bottom: pw.BorderSide(
//                                       color: PdfColor.fromInt(0xFFEEEEEE),
//                                     ),
//                                   ),
//                                 ),
//                                 child: pw.Row(
//                                   children: [
//                                     pw.Expanded(
//                                       flex: 5,
//                                       child: pw.Row(
//                                         children: [
//                                           pw.Text(
//                                             isDeduction ? 'X' : 'TOOL',
//                                             style: pw.TextStyle(
//                                               fontSize: 10,
//                                               fontWeight: pw.FontWeight.bold,
//                                             ),
//                                           ),
//                                           pw.SizedBox(width: 8),
//                                           pw.Expanded(
//                                             child: pw.Column(
//                                               crossAxisAlignment:
//                                                   pw.CrossAxisAlignment.start,
//                                               children: [
//                                                 pw.Text(
//                                                   service.serviceDescription,
//                                                   style: pw.TextStyle(
//                                                     fontWeight:
//                                                         pw.FontWeight.bold,
//                                                     fontSize: 13,
//                                                     color: isDeduction
//                                                         ? PdfColor.fromInt(
//                                                             0xFFD32F2F,
//                                                           )
//                                                         : PdfColors.black,
//                                                   ),
//                                                 ),
//                                                 if (isDeduction)
//                                                   pw.Text(
//                                                     'Already Paid - Deducted',
//                                                     style: pw.TextStyle(
//                                                       fontSize: 11,
//                                                       color: PdfColor.fromInt(
//                                                         0xFFB71C1C,
//                                                       ),
//                                                       fontStyle:
//                                                           pw.FontStyle.italic,
//                                                     ),
//                                                   ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     pw.Expanded(
//                                       flex: 2,
//                                       child: pw.Text(
//                                         service.quantity.toStringAsFixed(1),
//                                         textAlign: pw.TextAlign.center,
//                                         style: const pw.TextStyle(fontSize: 13),
//                                       ),
//                                     ),
//                                     pw.Expanded(
//                                       flex: 2,
//                                       child: pw.Text(
//                                         'Rs ${_formatNumber(service.rate)}',
//                                         textAlign: pw.TextAlign.right,
//                                         style: const pw.TextStyle(fontSize: 13),
//                                       ),
//                                     ),
//                                     pw.Expanded(
//                                       flex: 2,
//                                       child: pw.Text(
//                                         '${displayAmount >= 0 ? '' : '-'}Rs ${_formatNumber(displayAmount.abs())}',
//                                         textAlign: pw.TextAlign.right,
//                                         style: pw.TextStyle(
//                                           fontSize: 13,
//                                           fontWeight: pw.FontWeight.bold,
//                                           color: isDeduction
//                                               ? PdfColor.fromInt(0xFFD32F2F)
//                                               : PdfColors.black,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }),

//                             // Deductions
//                             ...deductions.map((deduction) {
//                               return pw.Container(
//                                 padding: const pw.EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 14,
//                                 ),
//                                 decoration: pw.BoxDecoration(
//                                   color: PdfColor.fromInt(0xFFFFEBEE),
//                                   border: pw.Border(
//                                     bottom: pw.BorderSide(
//                                       color: PdfColor.fromInt(0xFFFFCDD2),
//                                     ),
//                                   ),
//                                 ),
//                                 child: pw.Row(
//                                   children: [
//                                     pw.Expanded(
//                                       flex: 5,
//                                       child: pw.Row(
//                                         children: [
//                                           pw.Text(
//                                             'X',
//                                             style: pw.TextStyle(
//                                               fontSize: 10,
//                                               fontWeight: pw.FontWeight.bold,
//                                             ),
//                                           ),
//                                           pw.SizedBox(width: 8),
//                                           pw.Expanded(
//                                             child: pw.Text(
//                                               '${deduction.description} (Deduction)',
//                                               style: pw.TextStyle(
//                                                 fontWeight: pw.FontWeight.bold,
//                                                 fontSize: 13,
//                                                 color: PdfColor.fromInt(
//                                                   0xFFD32F2F,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     pw.Expanded(
//                                       flex: 2,
//                                       child: pw.Text(
//                                         '-',
//                                         textAlign: pw.TextAlign.center,
//                                       ),
//                                     ),
//                                     pw.Expanded(
//                                       flex: 2,
//                                       child: pw.Text(
//                                         '-',
//                                         textAlign: pw.TextAlign.right,
//                                       ),
//                                     ),
//                                     pw.Expanded(
//                                       flex: 2,
//                                       child: pw.Text(
//                                         '-Rs ${_formatNumber(deduction.amount)}',
//                                         textAlign: pw.TextAlign.right,
//                                         style: pw.TextStyle(
//                                           fontSize: 13,
//                                           fontWeight: pw.FontWeight.bold,
//                                           color: PdfColor.fromInt(0xFFD32F2F),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),

//                   pw.SizedBox(height: 24),

//                   // TOTAL SECTION
//                   pw.Container(
//                     width: double.infinity,
//                     padding: const pw.EdgeInsets.symmetric(horizontal: 24),
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.end,
//                       children: [
//                         pw.Container(
//                           width: 380,
//                           decoration: pw.BoxDecoration(
//                             borderRadius: pw.BorderRadius.circular(12),
//                             border: pw.Border.all(
//                               color: PdfColor.fromInt(0xFFE0E0E0),
//                             ),
//                           ),
//                           child: pw.Column(
//                             children: [
//                               // Subtotal
//                               _buildPDFTotalRow('Subtotal', document.subtotal),

//                               // Payment History
//                               if (document.type == DocumentType.invoice &&
//                                   document.paymentHistory.isNotEmpty) ...[
//                                 pw.Divider(height: 1),
//                                 ...document.paymentHistory.map((p) {
//                                   return pw.Container(
//                                     padding: const pw.EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                       vertical: 12,
//                                     ),
//                                     decoration: pw.BoxDecoration(
//                                       color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: pw.BorderSide(
//                                           color: PdfColor.fromInt(0xFFEEEEEE),
//                                         ),
//                                       ),
//                                     ),
//                                     child: pw.Column(
//                                       crossAxisAlignment:
//                                           pw.CrossAxisAlignment.stretch,
//                                       children: [
//                                         pw.Row(
//                                           mainAxisAlignment:
//                                               pw.MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             pw.Expanded(
//                                               child: pw.Row(
//                                                 children: [
//                                                   pw.Text(
//                                                     'OK',
//                                                     style: pw.TextStyle(
//                                                       fontSize: 10,
//                                                       fontWeight:
//                                                           pw.FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                   pw.SizedBox(width: 8),
//                                                   pw.Expanded(
//                                                     child: pw.Column(
//                                                       crossAxisAlignment: pw
//                                                           .CrossAxisAlignment
//                                                           .start,
//                                                       children: [
//                                                         pw.Text(
//                                                           'Paid (${p.description})',
//                                                           style: pw.TextStyle(
//                                                             fontSize: 13,
//                                                             color:
//                                                                 PdfColor.fromInt(
//                                                                   0xFF757575,
//                                                                 ),
//                                                             fontWeight: pw
//                                                                 .FontWeight
//                                                                 .bold,
//                                                           ),
//                                                         ),
//                                                         pw.Text(
//                                                           DateFormat(
//                                                             'dd MMM yyyy',
//                                                           ).format(p.date),
//                                                           style: pw.TextStyle(
//                                                             fontSize: 11,
//                                                             color:
//                                                                 PdfColor.fromInt(
//                                                                   0xFF9E9E9E,
//                                                                 ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             pw.Text(
//                                               '-Rs ${_formatNumber(p.amount)}',
//                                               style: pw.TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: pw.FontWeight.bold,
//                                                 color: PdfColor.fromInt(
//                                                   0xFF4CAF50,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 }),
//                               ],

//                               // AMOUNT DUE BOX - Full-width with rounded corners
//                               pw.Container(
//                                 width: double.infinity,
//                                 padding: const pw.EdgeInsets.all(16),
//                                 decoration: pw.BoxDecoration(
//                                   gradient: pw.LinearGradient(
//                                     colors:
//                                         document.status == DocumentStatus.paid
//                                         ? [
//                                             PdfColor.fromInt(0xFF4CAF50),
//                                             PdfColor.fromInt(0xFF66BB6A),
//                                           ]
//                                         : [
//                                             PdfColor.fromInt(0xFF43A047),
//                                             PdfColor(0.4, 0.8, 0.4, 1.0),
//                                           ],
//                                     begin: pw.Alignment.topLeft,
//                                     end: pw.Alignment.bottomRight,
//                                   ),
//                                   borderRadius: pw.BorderRadius.circular(
//                                     8,
//                                   ), // Rounded corners like UI
//                                 ),
//                                 child: pw.Row(
//                                   mainAxisAlignment:
//                                       pw.MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     pw.Row(
//                                       children: [
//                                         pw.Text(
//                                           document.status == DocumentStatus.paid
//                                               ? 'PAID'
//                                               : 'MONEY',
//                                           style: pw.TextStyle(
//                                             fontSize: 10,
//                                             fontWeight: pw.FontWeight.bold,
//                                           ),
//                                         ),
//                                         pw.SizedBox(width: 10),
//                                         pw.Text(
//                                           document.status == DocumentStatus.paid
//                                               ? 'PAID IN FULL'
//                                               : _isQuotation
//                                               ? 'ESTIMATED TOTAL'
//                                               : 'AMOUNT DUE',
//                                           style: pw.TextStyle(
//                                             color: PdfColors.white,
//                                             fontWeight: pw.FontWeight.bold,
//                                             fontSize: 14,
//                                             letterSpacing: 0.5,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     pw.Text(
//                                       document.status == DocumentStatus.paid
//                                           ? 'Rs 0.00'
//                                           : 'Rs ${_formatNumber(document.amountDue)}',
//                                       style: pw.TextStyle(
//                                         color: PdfColors.white,
//                                         fontWeight: pw.FontWeight.bold,
//                                         fontSize: 20,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   pw.SizedBox(height: 32),

//                   // PAYMENT INSTRUCTIONS
//                   pw.Container(
//                     padding: const pw.EdgeInsets.all(20),
//                     decoration: pw.BoxDecoration(
//                       color: PdfColor.fromInt(
//                         0xFFE3F2FD,
//                       ), // Colors.blue.shade50
//                       borderRadius: pw.BorderRadius.circular(12),
//                       border: pw.Border.all(
//                         color: PdfColor.fromInt(0xFFBBDEFB),
//                       ), // Colors.blue.shade100
//                     ),
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Row(
//                           children: [
//                             pw.Container(
//                               padding: const pw.EdgeInsets.all(8),
//                               decoration: pw.BoxDecoration(
//                                 color: PdfColor.fromInt(0xFFBBDEFB),
//                                 borderRadius: pw.BorderRadius.circular(8),
//                               ),
//                               child: pw.Text(
//                                 'BANK',
//                                 style: pw.TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: pw.FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             pw.SizedBox(width: 12),
//                             pw.Text(
//                               'PAYMENT INSTRUCTIONS',
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 fontSize: 14,
//                                 color: PdfColor.fromInt(
//                                   0xFF1976D2,
//                                 ), // Colors.blue.shade700
//                                 letterSpacing: 1,
//                               ),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 16),

//                         if (document.type == DocumentType.quotation ||
//                             (document.type == DocumentType.invoice &&
//                                 document.status != DocumentStatus.paid))
//                           _buildPDFInstructionItem(
//                             '1',
//                             'If you agreed, work commencement will proceed soon after receiving 75% of the quotation amount.',
//                           ),

//                         _buildPDFInstructionItem(
//                           '2',
//                           'It is essential to pay the amount remaining after the completion of work.',
//                         ),
//                         _buildPDFInstructionItem(
//                           '3',
//                           'Please deposit cash/fund transfer/cheque payments to the following account.',
//                         ),

//                         pw.SizedBox(height: 16),

//                         // Bank Details Card
//                         pw.Container(
//                           padding: const pw.EdgeInsets.all(16),
//                           decoration: pw.BoxDecoration(
//                             color: PdfColors.white,
//                             borderRadius: pw.BorderRadius.circular(8),
//                             border: pw.Border.all(
//                               color: PdfColor.fromInt(0xFFBBDEFB),
//                             ),
//                           ),
//                           child: pw.Row(
//                             children: [
//                               pw.Text(
//                                 'CARD',
//                                 style: pw.TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: pw.FontWeight.bold,
//                                 ),
//                               ),
//                               pw.SizedBox(width: 16),
//                               pw.Expanded(
//                                 child: pw.Column(
//                                   crossAxisAlignment:
//                                       pw.CrossAxisAlignment.start,
//                                   children: [
//                                     pw.Text(
//                                       'Bank Details',
//                                       style: pw.TextStyle(
//                                         fontSize: 12,
//                                         color: PdfColor.fromInt(0xFF9E9E9E),
//                                       ),
//                                     ),
//                                     pw.SizedBox(height: 4),
//                                     pw.Text(
//                                       'Immense Home (Pvt) Ltd',
//                                       style: pw.TextStyle(
//                                         fontWeight: pw.FontWeight.bold,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                     pw.Text(
//                                       'Hatton National Bank',
//                                       style: const pw.TextStyle(fontSize: 13),
//                                     ),
//                                     pw.Text(
//                                       'A/C No: 200010008304',
//                                       style: pw.TextStyle(
//                                         fontWeight: pw.FontWeight.bold,
//                                         fontSize: 14,
//                                         color: PdfColor.fromInt(0xFF1976D2),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   pw.SizedBox(height: 32),

//                   // TERMS & CONDITIONS
//                   pw.Container(
//                     padding: const pw.EdgeInsets.all(20),
//                     decoration: pw.BoxDecoration(
//                       color: PdfColor.fromInt(0xFFF5F5F5),
//                       borderRadius: pw.BorderRadius.circular(12),
//                       border: pw.Border.all(
//                         color: PdfColor.fromInt(0xFFE0E0E0),
//                       ),
//                     ),
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Row(
//                           children: [
//                             pw.Container(
//                               padding: const pw.EdgeInsets.all(8),
//                               decoration: pw.BoxDecoration(
//                                 color: PdfColor.fromInt(0xFFE0E0E0),
//                                 borderRadius: pw.BorderRadius.circular(8),
//                               ),
//                               child: pw.Text(
//                                 'DOC',
//                                 style: pw.TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: pw.FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             pw.SizedBox(width: 12),
//                             pw.Text(
//                               'TERMS & CONDITIONS',
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 fontSize: 14,
//                                 color: PdfColor.fromInt(0xFF757575),
//                                 letterSpacing: 1,
//                               ),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 16),
//                         pw.Text(
//                           '• All prices are in Sri Lankan Rupees (LKR)\n'
//                           '• This quotation is valid for 30 days from the date of issue\n'
//                           '• Payment terms: 75% advance, balance upon completion\n'
//                           '• Work will commence within 3-5 business days after advance payment\n'
//                           '• Any additional work beyond the scope will be charged separately',
//                           style: pw.TextStyle(
//                             fontSize: 12,
//                             color: PdfColor.fromInt(0xFF9E9E9E),
//                             lineSpacing: 1.6,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   pw.SizedBox(height: 32),

//                   // SIGNATURE SECTION
//                   pw.Row(
//                     crossAxisAlignment: pw.CrossAxisAlignment.end,
//                     children: [
//                       pw.Expanded(
//                         child: pw.Column(
//                           crossAxisAlignment: pw.CrossAxisAlignment.start,
//                           children: [
//                             pw.Text(
//                               'By signing this document, the customer agrees to the services and conditions described above.',
//                               style: pw.TextStyle(
//                                 fontSize: 12,
//                                 color: PdfColor.fromInt(0xFF9E9E9E),
//                                 fontStyle: pw.FontStyle.italic,
//                               ),
//                             ),
//                             pw.SizedBox(height: 24),
//                             pw.Row(
//                               children: [
//                                 // Customer Signature
//                                 pw.Expanded(
//                                   child: pw.Column(
//                                     crossAxisAlignment:
//                                         pw.CrossAxisAlignment.start,
//                                     children: [
//                                       pw.Container(
//                                         height: 60,
//                                         decoration: pw.BoxDecoration(
//                                           border: pw.Border(
//                                             bottom: pw.BorderSide(
//                                               color: PdfColor.fromInt(
//                                                 0xFFBDBDBD,
//                                               ),
//                                               width: 2,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       pw.SizedBox(height: 8),
//                                       pw.Text(
//                                         customerName.isEmpty
//                                             ? 'Customer Signature'
//                                             : customerName,
//                                         style: pw.TextStyle(
//                                           fontSize: 13,
//                                           fontWeight: pw.FontWeight.bold,
//                                           color: PdfColors.black,
//                                         ),
//                                       ),
//                                       pw.Text(
//                                         'Customer Signature & Date',
//                                         style: pw.TextStyle(
//                                           fontSize: 11,
//                                           color: PdfColor.fromInt(0xFF9E9E9E),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 pw.SizedBox(width: 40),
//                                 // Company Signature
//                                 pw.Expanded(
//                                   child: pw.Column(
//                                     crossAxisAlignment:
//                                         pw.CrossAxisAlignment.start,
//                                     children: [
//                                       pw.Container(
//                                         height: 60,
//                                         decoration: pw.BoxDecoration(
//                                           border: pw.Border(
//                                             bottom: pw.BorderSide(
//                                               color: PdfColor.fromInt(
//                                                 0xFFBDBDBD,
//                                               ),
//                                               width: 1,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       pw.SizedBox(height: 8),
//                                       pw.Text(
//                                         'Immense Home (Pvt) Ltd',
//                                         style: pw.TextStyle(
//                                           fontSize: 13,
//                                           fontWeight: pw.FontWeight.bold,
//                                           color: PdfColors.black,
//                                         ),
//                                       ),
//                                       pw.Text(
//                                         'Authorized Signature',
//                                         style: pw.TextStyle(
//                                           fontSize: 11,
//                                           color: PdfColor.fromInt(0xFF9E9E9E),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // FOOTER WATERMARK
//             pw.Container(
//               padding: const pw.EdgeInsets.symmetric(
//                 horizontal: 24,
//                 vertical: 16,
//               ),
//               decoration: pw.BoxDecoration(
//                 color: PdfColor.fromInt(0x0D43A047),
//                 borderRadius: pw.BorderRadius.only(
//                   bottomLeft: pw.Radius.circular(16),
//                   bottomRight: pw.Radius.circular(16),
//                 ),
//               ),
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.center,
//                 children: [
//                   pw.Text(
//                     'OK',
//                     style: pw.TextStyle(
//                       fontSize: 10,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                   pw.SizedBox(width: 8),
//                   pw.Text(
//                     'This is a computer-generated document. No signature is required.',
//                     style: pw.TextStyle(
//                       fontSize: 11,
//                       color: PdfColor.fromInt(0xB343A047),
//                       fontStyle: pw.FontStyle.italic,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ];
//         },
//       ),
//     );

//     // Direct Save PDF Option
//     await Printing.sharePdf(
//       bytes: await pdf.save(),
//       filename:
//           '${_title}_${document.documentNumber}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
//     );
//   }

//   // Print PDF method - opens print setup dialog
//   Future<void> _printPDF(BuildContext context) async {
//     final pdf = pw.Document();
//     final groupedItems = _groupLineItems();

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(35),
//         build: (pw.Context context) {
//           return [
//             // 1. TOP GREEN HEADER (Exactly like UI)
//             pw.Container(
//               padding: const pw.EdgeInsets.symmetric(
//                 horizontal: 15,
//                 vertical: 12,
//               ),
//               decoration: pw.BoxDecoration(
//                 color: PdfColor.fromInt(0xFF43A047), // UI Green
//                 borderRadius: const pw.BorderRadius.vertical(
//                   top: pw.Radius.circular(8),
//                 ),
//               ),
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Row(
//                     children: [
//                       pw.Container(
//                         width: 30,
//                         height: 30,
//                         decoration: pw.BoxDecoration(
//                           color: PdfColor(1.0, 1.0, 1.0, 0.2),
//                           borderRadius: pw.BorderRadius.circular(4),
//                         ),
//                         child: pw.Center(
//                           child: pw.Text(
//                             "IH",
//                             style: pw.TextStyle(
//                               color: PdfColors.white,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       pw.SizedBox(width: 10),
//                       pw.Text(
//                         _title,
//                         style: pw.TextStyle(
//                           color: PdfColors.white,
//                           fontSize: 18,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   // STATUS Badge එක මෙතනදී Render වෙන්නේ නැහැ (User's request)
//                 ],
//               ),
//             ),

//             // 2. COMPANY DETAILS AREA
//             pw.Container(
//               padding: const pw.EdgeInsets.all(15),
//               decoration: pw.BoxDecoration(
//                 color: PdfColors.white,
//                 border: pw.Border.all(color: PdfColors.grey200),
//               ),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     'IMMENSE HOME PRIVATE LIMITED',
//                     style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                   pw.SizedBox(height: 2),
//                   pw.Text(
//                     '157/1 OLD KOTTAWA ROAD, MIRIHANA, NUGEGODA',
//                     style: pw.TextStyle(fontSize: 9),
//                   ),
//                   pw.Text(
//                     'Website: www.immensehome.lk | 077 586 70 80',
//                     style: pw.TextStyle(fontSize: 9),
//                   ),
//                 ],
//               ),
//             ),

//             pw.SizedBox(height: 15),

//             // 3. BILL TO SECTION (Styled as Card)
//             pw.Container(
//               padding: const pw.EdgeInsets.all(12),
//               decoration: pw.BoxDecoration(
//                 border: pw.Border.all(color: PdfColors.grey300),
//                 borderRadius: pw.BorderRadius.circular(8),
//               ),
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text(
//                         'BILL TO',
//                         style: pw.TextStyle(
//                           fontWeight: pw.FontWeight.bold,
//                           color: PdfColor.fromInt(0xFF43A047),
//                         ),
//                       ),
//                       pw.SizedBox(height: 5),
//                       pw.Text(
//                         customerName,
//                         style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                       ),
//                       pw.Text(customerPhone, style: pw.TextStyle(fontSize: 10)),
//                       pw.Container(
//                         width: 150,
//                         child: pw.Text(
//                           customerAddress,
//                           style: pw.TextStyle(fontSize: 9),
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.end,
//                     children: [
//                       pw.Text(
//                         '$_title #: ${document.displayDocumentNumber}',
//                         style: pw.TextStyle(fontSize: 10),
//                       ),
//                       pw.Text(
//                         'Date: ${DateFormat('d MMM yyyy').format(document.invoiceDate)}',
//                         style: pw.TextStyle(fontSize: 10),
//                       ),
//                       pw.Text(
//                         'Due Date: ${DateFormat('d MMM yyyy').format(document.dueDate)}',
//                         style: pw.TextStyle(fontSize: 10),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             pw.SizedBox(height: 20),

//             // 4. ITEMS TABLE (Exactly matching Preview UI)
//             pw.Table(
//               columnWidths: {
//                 0: const pw.FlexColumnWidth(4),
//                 1: const pw.FlexColumnWidth(1),
//                 2: const pw.FlexColumnWidth(2),
//                 3: const pw.FlexColumnWidth(2),
//               },
//               children: [
//                 // Header
//                 pw.TableRow(
//                   decoration: pw.BoxDecoration(
//                     color: PdfColor.fromInt(0xFF43A047),
//                   ),
//                   children: ['Activity/Item', 'Qty', 'Price', 'Amount']
//                       .map(
//                         (text) => pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text(
//                             text,
//                             style: pw.TextStyle(
//                               color: PdfColors.white,
//                               fontWeight: pw.FontWeight.bold,
//                               fontSize: 10,
//                             ),
//                           ),
//                         ),
//                       )
//                       .toList(),
//                 ),
//                 // Items
//                 ...groupedItems.map(
//                   (item) => pw.TableRow(
//                     decoration: pw.BoxDecoration(
//                       border: pw.Border(
//                         bottom: pw.BorderSide(color: PdfColors.grey200),
//                       ),
//                     ),
//                     children: [
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(
//                           item.description,
//                           style: const pw.TextStyle(fontSize: 9),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(
//                           "${item.quantity} ${item.unit}",
//                           style: const pw.TextStyle(fontSize: 9),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(
//                           "Rs ${item.price.toStringAsFixed(2)}",
//                           style: const pw.TextStyle(fontSize: 9),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(
//                           "Rs ${item.amount.toStringAsFixed(2)}",
//                           textAlign: pw.TextAlign.right,
//                           style: pw.TextStyle(
//                             fontSize: 9,
//                             fontWeight: pw.FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             pw.SizedBox(height: 20),

//             // 5. SUMMARY SECTION (Right Aligned)
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.end,
//               children: [
//                 pw.Container(
//                   width: 220,
//                   child: pw.Column(
//                     children: [
//                       _buildPDFTotalRow('Subtotal', document.subtotal),
//                       pw.SizedBox(height: 5),
//                       // AMOUNT DUE - Solid Green Box like UI
//                       pw.Container(
//                         padding: const pw.EdgeInsets.all(10),
//                         decoration: pw.BoxDecoration(
//                           color: PdfColor.fromInt(0xFF43A047),
//                           borderRadius: pw.BorderRadius.circular(6),
//                         ),
//                         child: pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//                             pw.Text(
//                               'AMOUNT DUE',
//                               style: pw.TextStyle(
//                                 color: PdfColors.white,
//                                 fontWeight: pw.FontWeight.bold,
//                                 fontSize: 11,
//                               ),
//                             ),
//                             pw.Text(
//                               "Rs ${document.amountDue.toStringAsFixed(2)}",
//                               style: pw.TextStyle(
//                                 color: PdfColors.white,
//                                 fontWeight: pw.FontWeight.bold,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ];
//         },
//       ),
//     );

//     // Open print dialog
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//     );
//   }

//   // Helper for total rows

//   void _showFileSavedDialog(
//     BuildContext context,
//     String filePath,
//     String fileName,
//   ) {
//     final TextEditingController fileNameController = TextEditingController(
//       text: fileName,
//     );

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('PDF Saved Successfully'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.check_circle, color: Colors.green, size: 48),
//               const SizedBox(height: 16),
//               const Text('PDF has been saved to your device.'),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: fileNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'File Name',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 OpenFile.open(filePath);
//               },
//               child: const Text('Open File'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final newFileName = fileNameController.text.trim();
//                 if (newFileName.isNotEmpty && newFileName != fileName) {
//                   await _renameFile(filePath, newFileName);
//                 }
//                 Navigator.of(context).pop();
//                 OpenFile.open(
//                   newFileName.isNotEmpty
//                       ? filePath.replaceAll(fileName, newFileName)
//                       : filePath,
//                 );
//               },
//               child: const Text('Open & Rename'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _renameFile(String oldPath, String newFileName) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final newPath = '${directory.path}/$newFileName';

//       final oldFile = File(oldPath);
//       await oldFile.rename(newPath);
//     } catch (e) {
//       // Handle rename error silently
//       print('Error renaming file: $e');
//     }
//   }

//   pw.Widget _buildPDFHeader({bool isForPdf = false}) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(24),
//       decoration: pw.BoxDecoration(
//         gradient: pw.LinearGradient(
//           colors: [PdfColors.green, PdfColors.green600],
//           begin: pw.Alignment.topLeft,
//           end: pw.Alignment.bottomRight,
//         ),
//         borderRadius: pw.BorderRadius.only(
//           topLeft: pw.Radius.circular(16),
//           topRight: pw.Radius.circular(16),
//         ),
//       ),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           // Company Logo
//           pw.Container(
//             width: 80,
//             height: 80,
//             decoration: pw.BoxDecoration(
//               color: PdfColors.white,
//               borderRadius: pw.BorderRadius.circular(12),
//               boxShadow: [
//                 pw.BoxShadow(
//                   color: PdfColor(0, 0, 0, 0.2),
//                   blurRadius: 10,
//                   offset: PdfPoint(0, 4),
//                 ),
//               ],
//             ),
//             child: pw.Center(
//               child: pw.Text(
//                 'IH',
//                 style: pw.TextStyle(
//                   color: PdfColors.green700,
//                   fontSize: 28,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           pw.SizedBox(width: 20),

//           // Company Details
//           pw.Expanded(
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(
//                   'IMMENSE HOME',
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.white,
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 pw.Text(
//                   'PRIVATE LIMITED',
//                   style: pw.TextStyle(
//                     fontSize: 14,
//                     fontWeight: pw.FontWeight.normal,
//                     color: PdfColors.grey300,
//                     letterSpacing: 2,
//                   ),
//                 ),
//                 pw.SizedBox(height: 12),
//                 _buildPDFContactRow(
//                   'Address',
//                   '157/1 Old Kottawa Road, Mirihana, Nugegoda',
//                 ),
//                 _buildPDFContactRow('City', 'Colombo 81300'),
//                 _buildPDFContactRow('Phone', '077 586 70 80'),
//                 _buildPDFContactRow('Website', 'www.immensehome.lk'),
//                 _buildPDFContactRow(
//                   'Email',
//                   'immensehomeprivatelimited@gmail.com',
//                 ),
//               ],
//             ),
//           ),

//           // Document Type Badge - Only show in UI preview, not PDF
//           if (!isForPdf)
//             pw.Container(
//               padding: const pw.EdgeInsets.symmetric(
//                 horizontal: 24,
//                 vertical: 12,
//               ),
//               decoration: pw.BoxDecoration(
//                 color: PdfColor(1.0, 1.0, 1.0, 0.2),
//                 borderRadius: pw.BorderRadius.circular(8),
//                 border: pw.Border.all(color: PdfColors.grey200),
//               ),
//               child: pw.Text(
//                 _title,
//                 style: pw.TextStyle(
//                   color: PdfColors.white,
//                   fontSize: 22,
//                   fontWeight: pw.FontWeight.bold,
//                   letterSpacing: 2,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   PdfColor _getStatusColor() {
//     switch (document.status) {
//       case DocumentStatus.pending:
//         return PdfColors.orange;
//       case DocumentStatus.approved:
//         return PdfColors.blue;
//       case DocumentStatus.partial:
//         return PdfColors.purple;
//       case DocumentStatus.paid:
//         return PdfColors.green;
//       case DocumentStatus.converted:
//         return PdfColors.teal;
//       case DocumentStatus.closed:
//         return PdfColors.red;
//       default:
//         return PdfColors.grey;
//     }
//   }

//   PdfColor _getStatusBackgroundColor() {
//     switch (document.status) {
//       case DocumentStatus.pending:
//         return PdfColors.orange100;
//       case DocumentStatus.approved:
//         return PdfColors.blue100;
//       case DocumentStatus.partial:
//         return PdfColors.purple100;
//       case DocumentStatus.paid:
//         return PdfColors.green100;
//       case DocumentStatus.converted:
//         return PdfColors.teal100;
//       case DocumentStatus.closed:
//         return PdfColors.red100;
//       default:
//         return PdfColors.grey100;
//     }
//   }

//   pw.Widget _buildPDFDocumentInfo() {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(16),
//       decoration: pw.BoxDecoration(
//         color: PdfColors.grey100,
//         borderRadius: pw.BorderRadius.circular(4),
//       ),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//         children: [
//           _buildPDFInfoItem('$_title No.', document.displayDocumentNumber),
//           _buildPDFInfoItem(
//             'Issue Date',
//             DateFormat('dd MMM yyyy').format(document.invoiceDate),
//           ),
//           _buildPDFInfoItem(
//             'Due Date',
//             DateFormat('dd MMM yyyy').format(document.dueDate),
//           ),
//           _buildPDFInfoItem('Payment Terms', '${document.paymentTerms} Days'),
//         ],
//       ),
//     );
//   }

//   // Helper methods for PDF generation
//   pw.Widget _buildPDFDivider() {
//     return pw.Container(
//       height: 40,
//       width: 1,
//       color: PdfColor(0.8, 0.8, 0.8, 1.0),
//     );
//   }

//   pw.Widget _buildPDFInfoItem(String label, String value) {
//     return pw.Column(
//       children: [
//         pw.Text(
//           label,
//           style: pw.TextStyle(
//             fontSize: 9,
//             color: PdfColor(0.5, 0.5, 0.5, 1.0),
//             fontWeight: pw.FontWeight.bold,
//           ),
//         ),
//         pw.SizedBox(height: 4),
//         pw.Text(
//           value,
//           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
//         ),
//       ],
//     );
//   }

//   pw.Widget _buildPDFContactRow(String icon, String text) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.only(bottom: 4),
//       child: pw.Row(
//         children: [
//           pw.Container(
//             width: 14,
//             height: 14,
//             child: pw.Text(icon, style: pw.TextStyle(fontSize: 12)),
//           ),
//           pw.SizedBox(width: 8),
//           pw.Expanded(
//             child: pw.Text(
//               text,
//               style: pw.TextStyle(
//                 fontSize: 12,
//                 color: PdfColor.fromInt(0xFF757575), // Colors.grey.shade700
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   pw.Widget _buildPDFCustomerInfoRow(String emoji, String text) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.only(bottom: 6),
//       child: pw.Row(
//         children: [
//           pw.Text('$emoji ', style: pw.TextStyle(fontSize: 14)),
//           pw.Expanded(
//             child: pw.Text(
//               text,
//               style: pw.TextStyle(
//                 fontSize: 14,
//                 color: PdfColor(0.4, 0.4, 0.4, 1.0),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   pw.Widget _buildPDFInstructionItem(String number, String text) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.only(bottom: 8),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Container(
//             width: 22,
//             height: 22,
//             decoration: pw.BoxDecoration(
//               color: PdfColor(0.2, 0.4, 0.8, 1.0),
//               borderRadius: pw.BorderRadius.circular(11),
//             ),
//             child: pw.Center(
//               child: pw.Text(
//                 number,
//                 style: pw.TextStyle(
//                   color: PdfColors.white,
//                   fontSize: 12,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           pw.SizedBox(width: 12),
//           pw.Expanded(
//             child: pw.Text(
//               text,
//               style: pw.TextStyle(
//                 fontSize: 13,
//                 color: PdfColor(0.4, 0.4, 0.4, 1.0),
//                 lineSpacing: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   pw.Widget _buildPDFTotalRow(String label, double amount) {
//     final isNegative = amount < 0;
//     return pw.Container(
//       padding: const pw.EdgeInsets.symmetric(vertical: 6),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
//           pw.Text(
//             '${isNegative ? '-' : ''}Rs ${_formatNumber(amount.abs())}',
//             style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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

  _DeductionItem({required this.description, required this.amount});
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

  Color get _primaryColor =>
      _isQuotation ? const Color(0xFF1E88E5) : const Color(0xFF43A047);

  Color get _primaryLightColor =>
      _isQuotation ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9);

  Color get _accentColor => const Color(0xFF263238);

  String get _title => _isQuotation ? 'QUOTATION' : 'INVOICE';

  // PDF Colors
  PdfColor get _pdfPrimaryColor => _isQuotation
      ? PdfColor.fromInt(0xFF1E88E5)
      : PdfColor.fromInt(0xFF43A047);

  PdfColor get _pdfPrimaryDarkColor => _isQuotation
      ? PdfColor.fromInt(0xFF1565C0)
      : PdfColor.fromInt(0xFF2E7D32);

  PdfColor get _pdfPrimaryLightColor => _isQuotation
      ? PdfColor.fromInt(0xFFE3F2FD)
      : PdfColor.fromInt(0xFFE8F5E9);

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

  PdfColor get _pdfStatusColor {
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
          groupKey = name
              .replaceAll(' installation', '')
              .replaceAll(' labor', '');
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
        final hasMaterial = items.any(
          (item) =>
              item.item.name.toLowerCase().contains('material') ||
              item.item.name.toLowerCase().contains('tile'),
        );
        final hasLabor = items.any(
          (item) =>
              item.item.name.toLowerCase().contains('installation') ||
              item.item.name.toLowerCase().contains('labor'),
        );

        if (hasMaterial && hasLabor) {
          description = '$baseName & Installation';
        } else {
          description = items.map((item) => item.displayName).join(' + ');
        }
      }

      final totalQty = items.fold(0.0, (sum, item) => sum + item.quantity);

      result.add(
        _GroupedItem(
          description: description,
          quantity: items.length == 1 ? items[0].quantity : totalQty,
          price:
              totalAmount / (items.length == 1 ? items[0].quantity : totalQty),
          amount: totalAmount,
          unit: unit,
        ),
      );
    }

    return result;
  }

  List<_DeductionItem> _getPaidSiteVisitDeductions() {
    return document.lineItems
        .where(
          (item) =>
              item.item.type == ItemType.service &&
              item.item.name.toLowerCase().contains('site visit') &&
              item.item.servicePaymentStatus == ServicePaymentStatus.paid,
        )
        .map(
          (item) => _DeductionItem(
            description: item.displayName,
            amount: item.amount,
          ),
        )
        .toList();
  }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return NumberFormat('#,##0.00').format(number);
    }
    return number.toStringAsFixed(2);
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
              _isQuotation
                  ? Icons.description_outlined
                  : Icons.receipt_long_outlined,
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
                BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 4),
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
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary Actions Row (Save, Approve, Reject)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (document.status == DocumentStatus.pending) ...[
                // Approve Button
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Reject Button
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              // Save Button (only for pending status)
              if (document.status == DocumentStatus.pending)
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Secondary Actions Row (Save as PDF, Print) - Outlined Stadium Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Save as PDF Button
              OutlinedButton.icon(
                onPressed: () => _generateExactPDF(context),
                icon: const Icon(Icons.save),
                label: const Text('Save as PDF'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: const StadiumBorder(),
                  side: BorderSide(color: _primaryColor),
                  foregroundColor: _primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              // Print Button
              OutlinedButton.icon(
                onPressed: () => _printExactPDF(context),
                icon: const Icon(Icons.print),
                label: const Text('Print'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: const StadiumBorder(),
                  side: BorderSide(color: _accentColor),
                  foregroundColor: _accentColor,
                ),
              ),
            ],
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

  // ============ UI PREVIEW WIDGETS ============

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
                _buildContactRow(
                  Icons.location_on_outlined,
                  '157/1 Old Kottawa Road, Mirihana, Nugegoda',
                ),
                _buildContactRow(Icons.location_city_outlined, 'Colombo 81300'),
                _buildContactRow(Icons.phone_outlined, '077 586 70 80'),
                _buildContactRow(Icons.language_outlined, 'www.immensehome.lk'),
                _buildContactRow(
                  Icons.email_outlined,
                  'immensehomeprivatelimited@gmail.com',
                ),
              ],
            ),
          ),

          // Document Type Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
            Icons.tag,
            '$_title No.',
            document.displayDocumentNumber,
          ),
          _buildDivider(),
          _buildInfoItem(
            Icons.calendar_today,
            'Issue Date',
            DateFormat('dd MMM yyyy').format(document.invoiceDate),
          ),
          _buildDivider(),
          _buildInfoItem(
            Icons.event,
            'Due Date',
            DateFormat('dd MMM yyyy').format(document.dueDate),
          ),
          _buildDivider(),
          _buildInfoItem(
            Icons.access_time,
            'Payment Terms',
            '${document.paymentTerms} Days',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
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
    return Container(height: 40, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildBillToSection() {
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
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
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
              child: Icon(Icons.list_alt, color: _primaryColor, size: 20),
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
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _primaryColor.withOpacity(0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
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
                          'Rate',
                          textAlign: TextAlign.right,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                  final displayAmount = service.isAlreadyPaid
                      ? -service.amount
                      : service.amount;
                  final isDeduction = service.isAlreadyPaid;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isDeduction
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
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
                                isDeduction
                                    ? Icons.remove_circle_outline
                                    : Icons.build_outlined,
                                size: 16,
                                color: isDeduction
                                    ? Colors.red.shade700
                                    : Colors.blue.shade700,
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
                                        color: isDeduction
                                            ? Colors.red.shade700
                                            : _accentColor,
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
                              color: isDeduction
                                  ? Colors.red.shade700
                                  : _accentColor,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                        const Expanded(
                          flex: 2,
                          child: Text('-', textAlign: TextAlign.center),
                        ),
                        const Expanded(
                          flex: 2,
                          child: Text('-', textAlign: TextAlign.right),
                        ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildTotalRow('Subtotal', document.subtotal),
              if (document.type == DocumentType.invoice &&
                  document.paymentHistory.isNotEmpty) ...[
                const Divider(height: 1),
                ...document.paymentHistory.map((p) => _buildPaymentRow(p)),
              ],
              // Amount Due / Paid in Full
              Container(
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
    );
  }

  Widget _buildTotalRow(String label, double amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          Text(
            'Rs ${_formatNumber(amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(dynamic p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Colors.green.shade600,
                ),
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
    return Column(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade400,
                          width: 2,
                        ),
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
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade400,
                          width: 2,
                        ),
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
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
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

  // ============ EXACT PDF GENERATION ============

  Future<void> _generateExactPDF(BuildContext context) async {
    final pdf = pw.Document();
    final groupedItems = _groupLineItems();
    final deductions = _getPaidSiteVisitDeductions();

    // Load fonts
    final regularFont = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    // Split content into pages to prevent TooManyPagesException
    final List<pw.Widget> headerContent = [
      // Main container with border
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColor.fromInt(0xFFE0E0E0)),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            // ========== COMPANY HEADER ==========
            _buildPDFCompanyHeader(),

            // ========== DOCUMENT INFO BAR ==========
            _buildPDFDocumentInfoBar(),

            // ========== BILL TO SECTION ==========
            pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: _buildPDFBillToSection(),
            ),
          ],
        ),
      ),
    ];

    final List<pw.Widget> mainContent = [
      _buildPDFItemsTable(groupedItems, deductions),
    ];

    final List<pw.Widget> footerContent = [
     pw.Column(
          children: [
            // ========== TOTAL SECTION ==========
            pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: _buildPDFTotalSection(),
            ),

            pw.SizedBox(height: 16),

            // ========== PAYMENT INSTRUCTIONS ==========
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 24),
              child: _buildPDFPaymentInstructions(),
            ),

            pw.SizedBox(height: 16),

            // ========== TERMS & CONDITIONS ==========
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 24),
              child: _buildPDFTermsAndConditions(),
            ),

            pw.SizedBox(height: 16),

            // ========== SIGNATURE SECTION ==========
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 24),
              child: _buildPDFSignatureSection(),
            ),

            pw.SizedBox(height: 16),

            // ========== FOOTER WATERMARK ==========
            _buildPDFFooterWatermark(),
          ],
        ),
      
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        header: (pw.Context context) {
          if (context.pageNumber > 1) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF5F5F5),
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE0E0E0)),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '$_title - ${document.displayDocumentNumber}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Page ${context.pageNumber}',
                    style: pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
            );
          }
          return pw.SizedBox.shrink();
        },
        build: (pw.Context context) {
          return [
            // Header content on first page
            ...headerContent,
            pw.SizedBox(height: 20),

            // Main content (table)
            ...mainContent,
            pw.SizedBox(height: 20),

            // Footer content
            ...footerContent,
          ];
        },
      ),
    );

    // Save/Share PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          '${_title}_${document.documentNumber}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  Future<void> _printExactPDF(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final groupedItems = _groupLineItems();
      final deductions = _getPaidSiteVisitDeductions();

      // Load fonts explicitly to prevent layout issues
      final regularFont = await PdfGoogleFonts.nunitoRegular();
      final boldFont = await PdfGoogleFonts.nunitoBold();

      pdf.addPage(
        pw.MultiPage(
          maxPages: 20, // Prevent infinite loops
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
          header: (pw.Context context) {
            if (context.pageNumber > 1) {
              return pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF5F5F5),
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE0E0E0))),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('$_title - ${document.displayDocumentNumber} - Page ${context.pageNumber}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              );
            }
            return pw.SizedBox.shrink();
          },
          build: (pw.Context context) {
            return [
              // Header Section
              _buildPDFCompanyHeader(),
              pw.SizedBox(height: 10),

              // Document Info
              _buildPDFDocumentInfoBar(),
              pw.SizedBox(height: 10),

              // Bill To Section
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 24),
                child: _buildPDFBillToSection(),
              ),
              pw.SizedBox(height: 20),

              // Items Table - Allow page breaks
              _buildPDFItemsTable(groupedItems, deductions),
              pw.SizedBox(height: 15),

              // Total Section
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 24),
                child: _buildPDFTotalSection(),
              ),
              pw.SizedBox(height: 20),

              // Payment Instructions
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 24),
                child: _buildPDFPaymentInstructions(),
              ),
              pw.SizedBox(height: 20),

              // Terms & Conditions
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 24),
                child: _buildPDFTermsAndConditions(),
              ),
              pw.SizedBox(height: 20),

              // Signature Section
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 24),
                child: _buildPDFSignatureSection(),
              ),
              pw.SizedBox(height: 20),

              // Footer Watermark
              _buildPDFFooterWatermark(),
            ];
          },
        ),
      );

      // Open print dialog with proper error handling
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: '${_title}_${document.displayDocumentNumber}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      print("PDF Print Error: $e");
      // Show error dialog to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Print Error: $e')),
        );
      }
    }
  }

  // ========== PDF HELPER WIDGETS ==========

  pw.Widget _buildPDFCompanyHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        color: _pdfPrimaryLightColor,
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(8),
          topRight: pw.Radius.circular(8),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Logo
          pw.Container(
            width: 70,
            height: 70,
            decoration: pw.BoxDecoration(
              color: _pdfPrimaryColor,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Center(
              child: pw.Text(
                'IH',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 20),

          // Company Info
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'IMMENSE HOME',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF263238),
                    letterSpacing: 1,
                  ),
                ),
                pw.Text(
                  'PRIVATE LIMITED',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: _pdfPrimaryColor,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 10),
                _pdfContactRow('157/1 Old Kottawa Road, Mirihana, Nugegoda'),
                _pdfContactRow('Colombo 81300'),
                _pdfContactRow('077 586 70 80'),
                _pdfContactRow('www.immensehome.lk'),
                _pdfContactRow('immensehomeprivatelimited@gmail.com'),
              ],
            ),
          ),

          // Document Badge
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: pw.BoxDecoration(
                  color: _pdfPrimaryColor,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  _title,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: pw.BoxDecoration(
                  color: _pdfStatusColor.shade(0.9),
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: _pdfStatusColor.shade(0.7)),
                ),
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Container(
                      width: 8,
                      height: 8,
                      decoration: pw.BoxDecoration(
                        color: _pdfStatusColor,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      _statusText,
                      style: pw.TextStyle(
                        color: _pdfStatusColor,
                        fontSize: 10,
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

  pw.Widget _pdfContactRow(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        children: [
          pw.Container(
            width: 4,
            height: 4,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF9E9E9E),
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColor.fromInt(0xFF616161),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFDocumentInfoBar() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFAFAFA),
        border: pw.Border(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFFE0E0E0)),
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE0E0E0)),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _pdfInfoItem('$_title No.', document.displayDocumentNumber),
          _pdfDivider(),
          _pdfInfoItem(
            'Issue Date',
            DateFormat('dd MMM yyyy').format(document.invoiceDate),
          ),
          _pdfDivider(),
          _pdfInfoItem(
            'Due Date',
            DateFormat('dd MMM yyyy').format(document.dueDate),
          ),
          _pdfDivider(),
          _pdfInfoItem('Payment Terms', '${document.paymentTerms} Days'),
        ],
      ),
    );
  }

  pw.Widget _pdfInfoItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColor.fromInt(0xFF9E9E9E),
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColor.fromInt(0xFF263238),
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _pdfDivider() {
    return pw.Container(
      width: 1,
      height: 35,
      color: PdfColor.fromInt(0xFFE0E0E0),
    );
  }

  pw.Widget _buildPDFBillToSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              'BILL TO',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 13,
                color: _pdfPrimaryColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Text(
          customerName.isEmpty ? 'N/A' : customerName,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xFF263238),
          ),
        ),
        if (projectTitle.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: pw.BoxDecoration(
              color: _pdfPrimaryLightColor,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'Project: $projectTitle',
              style: pw.TextStyle(
                fontSize: 11,
                color: _pdfPrimaryColor,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
        pw.SizedBox(height: 10),
        if (customerPhone.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(
              'Tel: $customerPhone',
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColor.fromInt(0xFF616161),
              ),
            ),
          ),
        if (customerAddress.isNotEmpty)
          pw.Text(
            'Address: $customerAddress',
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColor.fromInt(0xFF616161),
            ),
          ),
      ],
    );
  }

  pw.Widget _buildPDFItemsTable(
    List<_GroupedItem> groupedItems,
    List<_DeductionItem> deductions,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Row(
          children: [
            pw.Text(
              'ITEMS & SERVICES',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 13,
                color: _pdfPrimaryColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 14),

        // Table
        pw.Container(
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(10),
            border: pw.Border.all(color: PdfColor.fromInt(0xFFE0E0E0)),
          ),
          child: pw.Column(
            children: [
              // Table Header
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: pw.BoxDecoration(
                  color: _pdfPrimaryColor,
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(9),
                    topRight: pw.Radius.circular(9),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(
                        'Description',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Qty',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Rate',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Amount',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Table Rows
              ...List.generate(groupedItems.length, (index) {
                final item = groupedItems[index];
                final isEven = index % 2 == 0;
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: pw.BoxDecoration(
                    color: isEven
                        ? PdfColors.white
                        : PdfColor.fromInt(0xFFFAFAFA),
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: PdfColor.fromInt(0xFFEEEEEE),
                      ),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 5,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.description,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 11,
                                color: PdfColor.fromInt(0xFF263238),
                              ),
                            ),
                            if (item.unit.isNotEmpty)
                              pw.Text(
                                'Unit: ${item.unit}',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColor.fromInt(0xFF9E9E9E),
                                ),
                              ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          item.quantity.toStringAsFixed(1),
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'Rs ${_formatNumber(item.price)}',
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'Rs ${_formatNumber(item.amount)}',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(0xFF263238),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Service Items
              ...document.serviceItems.map((service) {
                final displayAmount = service.isAlreadyPaid
                    ? -service.amount
                    : service.amount;
                final isDeduction = service.isAlreadyPaid;
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: pw.BoxDecoration(
                    color: isDeduction
                        ? PdfColor.fromInt(0xFFFFEBEE)
                        : PdfColor.fromInt(0xFFE3F2FD),
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: PdfColor.fromInt(0xFFEEEEEE),
                      ),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 5,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              service.serviceDescription,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 11,
                                color: isDeduction
                                    ? PdfColor.fromInt(0xFFC62828)
                                    : PdfColor.fromInt(0xFF263238),
                              ),
                            ),
                            if (isDeduction)
                              pw.Text(
                                'Already Paid - Deducted',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColor.fromInt(0xFFB71C1C),
                                  fontStyle: pw.FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          service.quantity.toStringAsFixed(1),
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'Rs ${_formatNumber(service.rate)}',
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          '${displayAmount >= 0 ? '' : '-'}Rs ${_formatNumber(displayAmount.abs())}',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: isDeduction
                                ? PdfColor.fromInt(0xFFC62828)
                                : PdfColor.fromInt(0xFF263238),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Deductions
              ...deductions.map((deduction) {
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFFFEBEE),
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: PdfColor.fromInt(0xFFFFCDD2),
                      ),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 5,
                        child: pw.Text(
                          '${deduction.description} (Deduction)',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 11,
                            color: PdfColor.fromInt(0xFFC62828),
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('-', textAlign: pw.TextAlign.center),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('-', textAlign: pw.TextAlign.right),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          '-Rs ${_formatNumber(deduction.amount)}',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(0xFFC62828),
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
      ],
    );
  }

  pw.Widget _buildPDFTotalSection() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 280,
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(10),
            border: pw.Border.all(color: PdfColor.fromInt(0xFFE0E0E0)),
          ),
          child: pw.Column(
            children: [
              // Subtotal
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFEEEEEE)),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Subtotal',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColor.fromInt(0xFF616161),
                      ),
                    ),
                    pw.Text(
                      'Rs ${_formatNumber(document.subtotal)}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF263238),
                      ),
                    ),
                  ],
                ),
              ),

              // Payment History
              if (document.type == DocumentType.invoice &&
                  document.paymentHistory.isNotEmpty)
                ...document.paymentHistory.map((p) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColor.fromInt(0xFFEEEEEE),
                        ),
                      ),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Paid (${p.description})',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColor.fromInt(0xFF616161),
                                ),
                              ),
                              pw.Text(
                                DateFormat('dd MMM yyyy').format(p.date),
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColor.fromInt(0xFF9E9E9E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Text(
                          '-Rs ${_formatNumber(p.amount)}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              // Amount Due
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: document.status == DocumentStatus.paid
                      ? PdfColor.fromInt(0xFF4CAF50)
                      : _pdfPrimaryColor,
                  borderRadius: const pw.BorderRadius.only(
                    bottomLeft: pw.Radius.circular(9),
                    bottomRight: pw.Radius.circular(9),
                  ),
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
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    pw.Text(
                      document.status == DocumentStatus.paid
                          ? 'Rs 0.00'
                          : 'Rs ${_formatNumber(document.amountDue)}',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 16,
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

  pw.Widget _buildPDFPaymentInstructions() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFE3F2FD),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFBBDEFB)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                'PAYMENT INSTRUCTIONS',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 13,
                  color: PdfColor.fromInt(0xFF1976D2),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          if (document.type == DocumentType.quotation ||
              (document.type == DocumentType.invoice &&
                  document.status != DocumentStatus.paid))
            _pdfInstructionItem(
              '1',
              'If you agreed, work commencement will proceed soon after receiving 75% of the quotation amount.',
            ),
          _pdfInstructionItem(
            '2',
            'It is essential to pay the amount remaining after the completion of work.',
          ),
          _pdfInstructionItem(
            '3',
            'Please deposit cash/fund transfer/cheque payments to the following account.',
          ),

          pw.SizedBox(height: 14),

          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColor.fromInt(0xFFBBDEFB)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Bank Details',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColor.fromInt(0xFF9E9E9E),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Immense Home (Pvt) Ltd',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Text(
                  'Hatton National Bank',
                  style: const pw.TextStyle(fontSize: 11),
                ),
                pw.Text(
                  'A/C No: 200010008304',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    color: PdfColor.fromInt(0xFF1976D2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfInstructionItem(String number, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 18,
            height: 18,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1976D2),
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                number,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColor.fromInt(0xFF616161),
                lineSpacing: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFTermsAndConditions() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFAFAFA),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFE0E0E0)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                'TERMS & CONDITIONS',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 13,
                  color: PdfColor.fromInt(0xFF757575),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            '• All prices are in Sri Lankan Rupees (LKR)\n'
            '• This quotation is valid for 30 days from the date of issue\n'
            '• Payment terms: 75% advance, balance upon completion\n'
            '• Work will commence within 3-5 business days after advance payment\n'
            '• Any additional work beyond the scope will be charged separately',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor.fromInt(0xFF9E9E9E),
              lineSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFSignatureSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'By signing this document, the customer agrees to the services and conditions described above.',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColor.fromInt(0xFF9E9E9E),
            fontStyle: pw.FontStyle.italic,
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    height: 50,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColor.fromInt(0xFFBDBDBD),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    customerName.isEmpty ? 'Customer Signature' : customerName,
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFF263238),
                    ),
                  ),
                  pw.Text(
                    'Customer Signature & Date',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColor.fromInt(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 30),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    height: 50,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColor.fromInt(0xFFBDBDBD),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Immense Home (Pvt) Ltd',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFF263238),
                    ),
                  ),
                  pw.Text(
                    'Authorized Signature',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColor.fromInt(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPDFFooterWatermark() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: pw.BoxDecoration(
        color: _pdfPrimaryLightColor,
        borderRadius: const pw.BorderRadius.only(
          bottomLeft: pw.Radius.circular(8),
          bottomRight: pw.Radius.circular(8),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'This is a computer-generated document. No signature is required.',
            style: pw.TextStyle(
              fontSize: 9,
              color: _pdfPrimaryColor.shade(0.5),
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
