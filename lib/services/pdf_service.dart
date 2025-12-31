// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
// import 'package:intl/intl.dart';
// import '../models/job_cost_report_models.dart';

// class JobCostPdfService {
//   static final currencyFormat = NumberFormat('#,##0.00', 'en_US');
//   static final dateFormat = DateFormat('dd MMM yyyy');

//   // Brand Colors
//   static const PdfColor primaryColor = PdfColor.fromInt(0xFF1565C0);
//   static const PdfColor secondaryColor = PdfColor.fromInt(0xFF42A5F5);
//   static const PdfColor accentColor = PdfColor.fromInt(0xFFFF6F00);
//   static const PdfColor successColor = PdfColor.fromInt(0xFF2E7D32);
//   static const PdfColor dangerColor = PdfColor.fromInt(0xFFC62828);
//   static const PdfColor lightGray = PdfColor.fromInt(0xFFF5F5F5);
//   static const PdfColor darkGray = PdfColor.fromInt(0xFF616161);

//   static Future<Uint8List> generateReport(JobCostReportData data) async {
//     final pdf = pw.Document();

//     // Use default Helvetica fonts
//     final ttfRegular = pw.Font.helvetica();
//     final ttfBold = pw.Font.helveticaBold();
//     final ttfItalic = pw.Font.helveticaOblique();

//     // Load logo
//     Uint8List? logoBytes;
//     try {
//       final logoData = await rootBundle.load(
//         'assets/images/immense_home_logo.png',
//       );
//       logoBytes = logoData.buffer.asUint8List();
//     } catch (e) {
//       print('Logo not found: $e');
//     }

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(40),
//         header: (context) =>
//             _buildHeader(context, logoBytes, ttfBold, ttfRegular),
//         footer: (context) => _buildFooter(context, ttfRegular, ttfItalic),
//         build: (context) => [
//           pw.SizedBox(
//             width: 515.28, // A4 width (595.28) minus margins (40*2)
//             child: pw.Column(
//               children: [
//                 _buildJobInfoSection(data, ttfBold, ttfRegular),
//                 pw.SizedBox(height: 20),
//                 _buildCustomerSection(data, ttfBold, ttfRegular),
//                 pw.SizedBox(height: 20),
//                 _buildMaterialCostTable(data, ttfBold, ttfRegular),
//                 pw.SizedBox(height: 20),
//                 if (data.laborCosts.isNotEmpty) ...[
//                   _buildLaborCostTable(data, ttfBold, ttfRegular),
//                   pw.SizedBox(height: 20),
//                 ],
//                 if (data.additionalCosts.isNotEmpty) ...[
//                   _buildAdditionalCostTable(data, ttfBold, ttfRegular),
//                   pw.SizedBox(height: 20),
//                 ],
//                 _buildFinancialOverview(data, ttfBold, ttfRegular),
//                 pw.SizedBox(height: 30),
//                 _buildSignatureSection(ttfBold, ttfRegular),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );

//     return pdf.save();
//   }

//   static pw.Widget _buildMaterialCostTable(
//     JobCostReportData data,
//     pw.Font boldFont,
//     pw.Font regularFont,
//   ) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Container(
//           padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//           decoration: const pw.BoxDecoration(
//             color: primaryColor,
//             borderRadius: pw.BorderRadius.only(
//               topLeft: pw.Radius.circular(5),
//               topRight: pw.Radius.circular(5),
//             ),
//           ),
//           child: pw.Row(
//             children: [
//               pw.Text(
//                 'MATERIAL COSTS',
//                 style: pw.TextStyle(
//                   font: boldFont,
//                   fontSize: 11,
//                   color: PdfColors.white,
//                 ),
//               ),
//               pw.Spacer(),
//               if (data.hasPendingCosts)
//                 pw.Container(
//                   padding: const pw.EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 2,
//                   ),
//                   decoration: pw.BoxDecoration(
//                     color: accentColor,
//                     borderRadius: pw.BorderRadius.circular(10),
//                   ),
//                   child: pw.Text(
//                     '⚠️ PENDING COSTS',
//                     style: pw.TextStyle(
//                       font: boldFont,
//                       fontSize: 8,
//                       color: PdfColors.white,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         pw.Container(
//           width: double.infinity,
//           child: pw.Table(
//             border: pw.TableBorder.all(color: PdfColors.grey300),
//             columnWidths: {
//               0: pw.FixedColumnWidth(40), // Code
//               1: pw.FixedColumnWidth(120), // Description
//               2: pw.FixedColumnWidth(40), // Qty
//               3: pw.FixedColumnWidth(60), // Cost (Rs.)
//               4: pw.FixedColumnWidth(60), // Sell (Rs.)
//               5: pw.FixedColumnWidth(70), // Total Cost
//             },
//             children: [
//               // Header Row
//               pw.TableRow(
//                 decoration: const pw.BoxDecoration(color: lightGray),
//                 children: [
//                   _buildTableHeader('Code', boldFont),
//                   _buildTableHeader('Description', boldFont),
//                   _buildTableHeader('Qty', boldFont),
//                   _buildTableHeader('Cost (Rs.)', boldFont),
//                   _buildTableHeader('Sell (Rs.)', boldFont),
//                   _buildTableHeader('Total Cost', boldFont),
//                 ],
//               ),
//               // Data Rows
//               ...data.items.map(
//                 (item) => pw.TableRow(
//                   children: [
//                     _buildTableCell(item.itemCode, regularFont),
//                     _buildTableCell(item.description, regularFont),
//                     _buildTableCell(
//                       '${item.quantity} ${item.unit}',
//                       regularFont,
//                     ),
//                     _buildCostCell(item, boldFont, regularFont),
//                     _buildTableCell(
//                       currencyFormat.format(item.sellingPrice),
//                       regularFont,
//                     ),
//                     _buildTableCell(
//                       item.isCostPending
//                           ? 'Pending'
//                           : currencyFormat.format(item.totalCost),
//                       regularFont,
//                       color: item.isCostPending ? accentColor : null,
//                     ),
//                   ],
//                 ),
//               ),
//               // Total Row
//               pw.TableRow(
//                 decoration: const pw.BoxDecoration(color: lightGray),
//                 children: [
//                   _buildTableCell('', regularFont),
//                   _buildTableCell('', regularFont),
//                   _buildTableCell('', regularFont),
//                   _buildTableCell('', regularFont),
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.all(6),
//                     child: pw.Text(
//                       'TOTAL:',
//                       style: pw.TextStyle(font: boldFont, fontSize: 9),
//                       textAlign: pw.TextAlign.right,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.all(6),
//                     child: pw.Text(
//                       'Rs. ${currencyFormat.format(data.totalMaterialCost)}',
//                       style: pw.TextStyle(font: boldFont, fontSize: 9),
//                       textAlign: pw.TextAlign.right,
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

//   static pw.Widget _buildCostCell(
//     JobCostItem item,
//     pw.Font boldFont,
//     pw.Font regularFont,
//   ) {
//     if (item.isCostPending) {
//       return pw.Container(
//         padding: const pw.EdgeInsets.all(4),
//         child: pw.Container(
//           padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//           decoration: pw.BoxDecoration(
//             color: accentColor,
//             borderRadius: pw.BorderRadius.circular(3),
//           ),
//           child: pw.Text(
//             'PENDING',
//             style: pw.TextStyle(
//               font: boldFont,
//               fontSize: 7,
//               color: PdfColors.white,
//             ),
//             textAlign: pw.TextAlign.center,
//           ),
//         ),
//       );
//     }
//     return _buildTableCell(currencyFormat.format(item.costPrice), regularFont);
//   }

//   static pw.Widget _buildTableHeader(String text, pw.Font font) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(6),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(font: font, fontSize: 9),
//         textAlign: pw.TextAlign.center,
//       ),
//     );
//   }

//   static pw.Widget _buildTableCell(
//     String text,
//     pw.Font font, {
//     PdfColor? color,
//   }) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(6),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(font: font, fontSize: 8, color: color),
//         textAlign: pw.TextAlign.left,
//       ),
//     );
//   }

//   static pw.Widget _buildLaborCostTable(
//     JobCostReportData data,
//     pw.Font boldFont,
//     pw.Font regularFont,
//   ) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Container(
//           padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//           decoration: const pw.BoxDecoration(
//             color: secondaryColor,
//             borderRadius: pw.BorderRadius.only(
//               topLeft: pw.Radius.circular(5),
//               topRight: pw.Radius.circular(5),
//             ),
//           ),
//           child: pw.Row(
//             children: [
//               pw.Text(
//                 'LABOR COSTS',
//                 style: pw.TextStyle(
//                   font: boldFont,
//                   fontSize: 11,
//                   color: PdfColors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         pw.Container(
//           width: double.infinity,
//           child: pw.Table(
//             border: pw.TableBorder.all(color: PdfColors.grey300),
//             columnWidths: {
//               0: pw.FixedColumnWidth(100), // Description
//               1: pw.FixedColumnWidth(80), // Worker
//               2: pw.FixedColumnWidth(40), // Days
//               3: pw.FixedColumnWidth(60), // Daily Rate
//               4: pw.FixedColumnWidth(70), // Total
//             },
//             children: [
//               pw.TableRow(
//                 decoration: const pw.BoxDecoration(color: lightGray),
//                 children: [
//                   _buildTableHeader('Description', boldFont),
//                   _buildTableHeader('Worker', boldFont),
//                   _buildTableHeader('Days', boldFont),
//                   _buildTableHeader('Daily Rate', boldFont),
//                   _buildTableHeader('Total', boldFont),
//                 ],
//               ),
//               ...data.laborCosts.map(
//                 (labor) => pw.TableRow(
//                   children: [
//                     _buildTableCell(labor.description, regularFont),
//                     _buildTableCell(labor.workerName, regularFont),
//                     _buildTableCell(labor.days.toString(), regularFont),
//                     _buildTableCell(
//                       currencyFormat.format(labor.dailyRate),
//                       regularFont,
//                     ),
//                     _buildTableCell(
//                       currencyFormat.format(labor.totalCost),
//                       regularFont,
//                     ),
//                   ],
//                 ),
//               ),
//               pw.TableRow(
//                 decoration: const pw.BoxDecoration(color: lightGray),
//                 children: [
//                   _buildTableCell('', regularFont),
//                   _buildTableCell('', regularFont),
//                   _buildTableCell('', regularFont),
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.all(6),
//                     child: pw.Text(
//                       'TOTAL:',
//                       style: pw.TextStyle(font: boldFont, fontSize: 9),
//                       textAlign: pw.TextAlign.right,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.all(6),
//                     child: pw.Text(
//                       'Rs. ${currencyFormat.format(data.totalLaborCost)}',
//                       style: pw.TextStyle(font: boldFont, fontSize: 9),
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

//   static pw.Widget _buildAdditionalCostTable(
//     JobCostReportData data,
//     pw.Font boldFont,
//     pw.Font regularFont,
//   ) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Container(
//           padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//           decoration: const pw.BoxDecoration(
//             color: accentColor,
//             borderRadius: pw.BorderRadius.only(
//               topLeft: pw.Radius.circular(5),
//               topRight: pw.Radius.circular(5),
//             ),
//           ),
//           child: pw.Text(
//             'ADDITIONAL COSTS (Transport, Tools, etc.)',
//             style: pw.TextStyle(
//               font: boldFont,
//               fontSize: 11,
//               color: PdfColors.white,
//             ),
//           ),
//         ),
//         pw.Container(
//           width: double.infinity,
//           child: pw.Table(
//             border: pw.TableBorder.all(color: PdfColors.grey300),
//             columnWidths: {
//               0: pw.FixedColumnWidth(200), // Description
//               1: pw.FixedColumnWidth(80), // Category
//               2: pw.FixedColumnWidth(70), // Amount
//             },
//             children: [
//               pw.TableRow(
//                 decoration: const pw.BoxDecoration(color: lightGray),
//                 children: [
//                   _buildTableHeader('Description', boldFont),
//                   _buildTableHeader('Category', boldFont),
//                   _buildTableHeader('Amount (Rs.)', boldFont),
//                 ],
//               ),
//               ...data.additionalCosts.map(
//                 (cost) => pw.TableRow(
//                   children: [
//                     _buildTableCell(cost.description, regularFont),
//                     _buildTableCell(cost.category, regularFont),
//                     _buildTableCell(
//                       currencyFormat.format(cost.amount),
//                       regularFont,
//                     ),
//                   ],
//                 ),
//               ),
//               pw.TableRow(
//                 decoration: const pw.BoxDecoration(color: lightGray),
//                 children: [
//                   _buildTableCell('', regularFont),
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.all(6),
//                     child: pw.Text(
//                       'TOTAL:',
//                       style: pw.TextStyle(font: boldFont, fontSize: 9),
//                       textAlign: pw.TextAlign.right,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.all(6),
//                     child: pw.Text(
//                       'Rs. ${currencyFormat.format(data.totalAdditionalCost)}',
//                       style: pw.TextStyle(font: boldFont, fontSize: 9),
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

//   static pw.Widget _buildFinancialOverview(
//     JobCostReportData data,
//     pw.Font boldFont,
//     pw.Font regularFont,
//   ) {
//     final isProfit = data.netProfit >= 0;

//     return pw.Container(
//       padding: const pw.EdgeInsets.all(15),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: primaryColor, width: 2),
//         borderRadius: pw.BorderRadius.circular(8),
//       ),
//       child: pw.Column(
//         children: [
//           pw.Text(
//             '📊 FINANCIAL OVERVIEW',
//             style: pw.TextStyle(
//               font: boldFont,
//               fontSize: 14,
//               color: primaryColor,
//             ),
//           ),
//           pw.Divider(color: primaryColor),
//           pw.SizedBox(height: 10),
//           pw.Row(
//             children: [
//               // Cost Summary
//               pw.Expanded(
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     _buildFinancialRow(
//                       'Material Cost:',
//                       'Rs. ${currencyFormat.format(data.totalMaterialCost)}',
//                       boldFont,
//                       regularFont,
//                     ),
//                     _buildFinancialRow(
//                       'Labor Cost:',
//                       'Rs. ${currencyFormat.format(data.totalLaborCost)}',
//                       boldFont,
//                       regularFont,
//                     ),
//                     _buildFinancialRow(
//                       'Additional Cost:',
//                       'Rs. ${currencyFormat.format(data.totalAdditionalCost)}',
//                       boldFont,
//                       regularFont,
//                     ),
//                     pw.Divider(),
//                     _buildFinancialRow(
//                       'TOTAL COST:',
//                       'Rs. ${currencyFormat.format(data.totalCost)}',
//                       boldFont,
//                       regularFont,
//                       isTotal: true,
//                     ),
//                   ],
//                 ),
//               ),
//               pw.Container(width: 1, height: 100, color: PdfColors.grey300),
//               pw.SizedBox(width: 20),
//               // Revenue Summary
//               pw.Expanded(
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     _buildFinancialRow(
//                       'Total Invoiced:',
//                       'Rs. ${currencyFormat.format(data.totalInvoiced)}',
//                       boldFont,
//                       regularFont,
//                     ),
//                     _buildFinancialRow(
//                       'Advance Received:',
//                       'Rs. ${currencyFormat.format(data.advanceReceived)}',
//                       boldFont,
//                       regularFont,
//                     ),
//                     _buildFinancialRow(
//                       'Balance Due:',
//                       'Rs. ${currencyFormat.format(data.totalInvoiced - data.advanceReceived)}',
//                       boldFont,
//                       regularFont,
//                     ),
//                     pw.Divider(),
//                     _buildFinancialRow(
//                       'Gross Profit:',
//                       'Rs. ${currencyFormat.format(data.grossProfit)}',
//                       boldFont,
//                       regularFont,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           pw.SizedBox(height: 15),
//           // Net Profit Highlight Box
//           pw.Container(
//             width: double.infinity,
//             padding: const pw.EdgeInsets.all(15),
//             decoration: pw.BoxDecoration(
//               color: isProfit ? successColor : dangerColor,
//               borderRadius: pw.BorderRadius.circular(8),
//             ),
//             child: pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.center,
//               children: [
//                 pw.Text(
//                   isProfit ? '✓ NET PROFIT: ' : '✗ NET LOSS: ',
//                   style: pw.TextStyle(
//                     font: boldFont,
//                     fontSize: 16,
//                     color: PdfColors.white,
//                   ),
//                 ),
//                 pw.Text(
//                   'Rs. ${currencyFormat.format(data.netProfit.abs())}',
//                   style: pw.TextStyle(
//                     font: boldFont,
//                     fontSize: 18,
//                     color: PdfColors.white,
//                   ),
//                 ),
//                 pw.SizedBox(width: 20),
//                 pw.Container(
//                   padding: const pw.EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 5,
//                   ),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.white,
//                     borderRadius: pw.BorderRadius.circular(15),
//                   ),
//                   child: pw.Text(
//                     '${data.profitMargin.toStringAsFixed(1)}%',
//                     style: pw.TextStyle(
//                       font: boldFont,
//                       fontSize: 12,
//                       color: isProfit ? successColor : dangerColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Warning for pending costs
//           if (data.hasPendingCosts) ...[
//             pw.Container(
//               margin: const pw.EdgeInsets.only(top: 10),
//               padding: const pw.EdgeInsets.all(8),
//               decoration: pw.BoxDecoration(
//                 color: const PdfColor.fromInt(0xFFFFF3E0),
//                 borderRadius: pw.BorderRadius.circular(5),
//                 border: pw.Border.all(color: accentColor),
//               ),
//               child: pw.Row(
//                 children: [
//                   pw.Text('⚠️ ', style: const pw.TextStyle(fontSize: 12)),
//                   pw.Expanded(
//                     child: pw.Text(
//                       'Note: Some items have pending cost prices. Please update them for accurate profit calculation.',
//                       style: pw.TextStyle(
//                         font: regularFont,
//                         fontSize: 9,
//                         color: accentColor,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   static pw.Widget _buildFinancialRow(
//     String label,
//     String value,
//     pw.Font boldFont,
//     pw.Font regularFont, {
//     bool isTotal = false,
//   }) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 2),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(
//             label,
//             style: pw.TextStyle(
//               font: isTotal ? boldFont : regularFont,
//               fontSize: isTotal ? 10 : 9,
//             ),
//           ),
//           pw.Text(
//             value,
//             style: pw.TextStyle(
//               font: isTotal ? boldFont : regularFont,
//               fontSize: isTotal ? 10 : 9,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static pw.Widget _buildSignatureSection(
//     pw.Font boldFont,
//     pw.Font regularFont,
//   ) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(15),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.grey300),
//         borderRadius: pw.BorderRadius.circular(5),
//       ),
//       child: pw.Row(
//         children: [
//           // Prepared By
//           pw.Expanded(
//             child: pw.Column(
//               children: [
//                 pw.Container(
//                   height: 50,
//                   decoration: const pw.BoxDecoration(
//                     border: pw.Border(
//                       bottom: pw.BorderSide(color: PdfColors.grey400),
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 5),
//                 pw.Text(
//                   'Prepared By',
//                   style: pw.TextStyle(font: boldFont, fontSize: 9),
//                 ),
//                 pw.Text(
//                   'Date: _______________',
//                   style: pw.TextStyle(font: regularFont, fontSize: 8),
//                 ),
//               ],
//             ),
//           ),
//           pw.SizedBox(width: 30),
//           // Verified By
//           pw.Expanded(
//             child: pw.Column(
//               children: [
//                 pw.Container(
//                   height: 50,
//                   decoration: const pw.BoxDecoration(
//                     border: pw.Border(
//                       bottom: pw.BorderSide(color: PdfColors.grey400),
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 5),
//                 pw.Text(
//                   'Verified By',
//                   style: pw.TextStyle(font: boldFont, fontSize: 9),
//                 ),
//                 pw.Text(
//                   'Date: _______________',
//                   style: pw.TextStyle(font: regularFont, fontSize: 8),
//                 ),
//               ],
//             ),
//           ),
//           pw.SizedBox(width: 30),
//           // Approved By
//           pw.Expanded(
//             child: pw.Column(
//               children: [
//                 pw.Container(
//                   height: 50,
//                   decoration: const pw.BoxDecoration(
//                     border: pw.Border(
//                       bottom: pw.BorderSide(color: PdfColors.grey400),
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 5),
//                 pw.Text(
//                   'Approved By (Director)',
//                   style: pw.TextStyle(font: boldFont, fontSize: 9),
//                 ),
//                 pw.Text(
//                   'Date: _______________',
//                   style: pw.TextStyle(font: regularFont, fontSize: 8),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static pw.Widget _buildFooter(
//     pw.Context context,
//     pw.Font regularFont,
//     pw.Font italicFont,
//   ) {
//     return pw.Container(
//       decoration: const pw.BoxDecoration(
//         border: pw.Border(top: pw.BorderSide(color: primaryColor, width: 2)),
//       ),
//       padding: const pw.EdgeInsets.only(top: 10),
//       child: pw.Column(
//         children: [
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Text(
//                 'Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
//                 style: pw.TextStyle(
//                   font: regularFont,
//                   fontSize: 8,
//                   color: darkGray,
//                 ),
//               ),
//               pw.Text(
//                 'Page ${context.pageNumber} of ${context.pagesCount}',
//                 style: pw.TextStyle(
//                   font: regularFont,
//                   fontSize: 8,
//                   color: darkGray,
//                 ),
//               ),
//             ],
//           ),
//           pw.SizedBox(height: 5),
//           pw.Text(
//             'This is a computer-generated document. For queries, contact: ${CompanyInfo.email}',
//             style: pw.TextStyle(font: italicFont, fontSize: 7, color: darkGray),
//           ),
//           pw.SizedBox(height: 3),
//           pw.Text(
//             '© ${DateTime.now().year} ${CompanyInfo.name}. All Rights Reserved.',
//             style: pw.TextStyle(
//               font: regularFont,
//               fontSize: 7,
//               color: darkGray,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static pw.Widget _buildHeader(
//     pw.Context context,
//     Uint8List? logoBytes,
//     pw.Font boldFont,
//     pw.Font regularFont,
//   ) {
//     return pw.Container(
//       decoration: pw.BoxDecoration(
//         border: pw.Border(bottom: pw.BorderSide(color: primaryColor, width: 3)),
//       ),
//       padding: const pw.EdgeInsets.only(bottom: 15),
//       margin: const pw.EdgeInsets.only(bottom: 20),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           // Logo Section
//           logoBytes != null
//               ? pw.Container(
//                   width: 80,
//                   height: 80,
//                   child: pw.Image(pw.MemoryImage(logoBytes)),
//                 )
//               : pw.Container(
//                   width: 80,
//                   height: 80,
//                   decoration: pw.BoxDecoration(
//                     color: primaryColor,
//                     borderRadius: pw.BorderRadius.circular(10),
//                   ),
//                   child: pw.Center(
//                     child: pw.Text(
//                       'IH',
//                       style: pw.TextStyle(
//                         font: boldFont,
//                         fontSize: 32,
//                         color: PdfColors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//           pw.SizedBox(width: 20),

//           // Company Details
//           pw.Expanded(
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(
//                   CompanyInfo.name,
//                   style: pw.TextStyle(
//                     font: boldFont,
//                     fontSize: 20,
//                     color: primaryColor,
//                   ),
//                 ),
//                 pw.SizedBox(height: 3),
//                 pw.Text(
//                   CompanyInfo.tagline,
//                   style: pw.TextStyle(
//                     font: regularFont,
//                     fontSize: 9,
//                     color: darkGray,
//                     fontStyle: pw.FontStyle.italic,
//                   ),
//                 ),
//                 pw.SizedBox(height: 8),
//                 pw.Row(
//                   children: [
//                     pw.Icon(pw.IconData(0xe0cd), size: 10, color: primaryColor),
//                     pw.SizedBox(width: 5),
//                     pw.Text(
//                       CompanyInfo.address1,
//                       style: pw.TextStyle(font: regularFont, fontSize: 8),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 2),
//                 pw.Row(
//                   children: [
//                     pw.Icon(pw.IconData(0xe0cd), size: 10, color: primaryColor),
//                     pw.SizedBox(width: 5),
//                     pw.Text(
//                       CompanyInfo.address2,
//                       style: pw.TextStyle(font: regularFont, fontSize: 8),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Contact Details
//           pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.end,
//             children: [
//               pw.Container(
//                 padding: const pw.EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: pw.BoxDecoration(
//                   color: primaryColor,
//                   borderRadius: pw.BorderRadius.circular(5),
//                 ),
//                 child: pw.Text(
//                   'JOB COST REPORT',
//                   style: pw.TextStyle(
//                     font: boldFont,
//                     fontSize: 12,
//                     color: PdfColors.white,
//                   ),
//                 ),
//               ),
//               pw.SizedBox(height: 10),
//               _buildContactRow('📞', CompanyInfo.phone, regularFont),
//               pw.SizedBox(height: 3),
//               _buildContactRow('✉️', CompanyInfo.email, regularFont),
//               pw.SizedBox(height: 3),
//               _buildContactRow('🌐', CompanyInfo.website, regularFont),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   static pw.Widget _buildContactRow(String icon, String text, pw.Font font) {
//     return pw.Row(
//       mainAxisSize: pw.MainAxisSize.min,
//       children: [
//         pw.Text(icon, style: pw.TextStyle(fontSize: 8)),
//         pw.SizedBox(width: 5),
//         pw.Text(
//           text,
//           style: pw.TextStyle(font: font, fontSize: 8, color: darkGray),
//         ),
//       ],
//     );
//   }

//   static pw.Widget _buildJobInfoSection(
//     JobCostReportData data,
//     pw.Font boldFont,
//     pw.Font regularFont,
//   ) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(15),
//       decoration: pw.BoxDecoration(
//         color: lightGray,
//         borderRadius: pw.BorderRadius.circular(8),
//         border: pw.Border.all(color: PdfColors.grey300),
//       ),
//       child: pw.Row(
//         children: [
//           pw.Expanded(
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Row(
//                   children: [
//                     pw.Text(
//                       'Job ID: ',
//                       style: pw.TextStyle(font: boldFont, fontSize: 14),
//                     ),
//                     pw.Text(
//                       data.jobId,
//                       style: pw.TextStyle(
//                         font: boldFont,
//                         fontSize: 14,
//                         color: primaryColor,
//                       ),
//                     ),
//                     pw.SizedBox(width: 15),
//                     // Status Badge
//                     pw.Container(
//                       padding: const pw.EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 4,
//                       ),
//                       decoration: pw.BoxDecoration(
//                         color: _getStatusColor(data.status),
//                         borderRadius: pw.BorderRadius.circular(12),
//                       ),
//                       child: pw.Text(
//                         data.status.displayName.toUpperCase(),
//                         style: pw.TextStyle(
//                           font: boldFont,
//                           fontSize: 9,
//                           color: PdfColors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 8),
//                 pw.Text(
//                   'Quotation: ${data.quotationNumber}',
//                   style: pw.TextStyle(font: regularFont, fontSize: 10),
//                 ),
//                 pw.SizedBox(height: 4),
//                 pw.Text(
//                   'Project: ${data.projectDescription}',
//                   style: pw.TextStyle(font: regularFont, fontSize: 10),
//                 ),
//               ],
//             ),
//           ),
//           pw.Container(
//             padding: const pw.EdgeInsets.all(10),
//             decoration: pw.BoxDecoration(
//               border: pw.Border.all(color: primaryColor),
//               borderRadius: pw.BorderRadius.circular(5),
//             ),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.end,
//               children: [
//                 pw.Text(
//                   'Start Date',
//                   style: pw.TextStyle(
//                     font: regularFont,
//                     fontSize: 8,
//                     color: darkGray,
//                   ),
//                 ),
//                 pw.Text(
//                   dateFormat.format(data.startDate),
//                   style: pw.TextStyle(font: boldFont, fontSize: 10),
//                 ),
//                 pw.SizedBox(height: 5),
//                 pw.Text(
//                   'End Date',
//                   style: pw.TextStyle(
//                     font: regularFont,
//                     fontSize: 8,
//                     color: darkGray,
//                   ),
//                 ),
//                 pw.Text(
//                   data.endDate != null
//                       ? dateFormat.format(data.endDate!)
//                       : 'Ongoing',
//                   style: pw.TextStyle(font: boldFont, fontSize: 10),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static PdfColor _getStatusColor(ProjectStatus status) {
//     switch (status) {
//       case ProjectStatus.active:
//         return const PdfColor.fromInt(0xFF1976D2);
//       case ProjectStatus.invoiced:
//         return const PdfColor.fromInt(0xFFFF9800);
//       case ProjectStatus.completed:
//         return const PdfColor.fromInt(0xFF4CAF50);
//       case ProjectStatus.pending:
//         return const PdfColor.fromInt(0xFFFFC107);
//       case ProjectStatus.cancelled:
//         return const PdfColor.fromInt(0xFFF44336);
//     }
//   }

//   static pw.Widget _buildCustomerSection(
//     JobCostReportData data,
//     pw.Font boldFont,
//     pw.Font regularFont,
//   ) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(12),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.grey300),
//         borderRadius: pw.BorderRadius.circular(5),
//       ),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text(
//             'CUSTOMER INFORMATION',
//             style: pw.TextStyle(
//               font: boldFont,
//               fontSize: 10,
//               color: primaryColor,
//             ),
//           ),
//           pw.Divider(color: PdfColors.grey300),
//           pw.SizedBox(height: 5),
//           pw.Row(
//             children: [
//               pw.Expanded(
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     _buildInfoRow(
//                       'Name:',
//                       data.customerName,
//                       boldFont,
//                       regularFont,
//                     ),
//                     _buildInfoRow(
//                       'Address:',
//                       data.customerAddress,
//                       boldFont,
//                       regularFont,
//                     ),
//                   ],
//                 ),
//               ),
//               pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   _buildInfoRow(
//                     'Phone:',
//                     data.customerPhone,
//                     boldFont,
//                     regularFont,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   static pw.Widget _buildInfoRow(
//     String label,
//     String value,
//     pw.Font boldFont,
//     pw.Font regularFont,
//   ) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.only(bottom: 3),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.SizedBox(
//             width: 60,
//             child: pw.Text(
//               label,
//               style: pw.TextStyle(font: boldFont, fontSize: 9),
//             ),
//           ),
//           pw.Expanded(
//             child: pw.Text(
//               value,
//               style: pw.TextStyle(font: regularFont, fontSize: 9),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static Future<void> _saveAndOpenPDF(pw.Document pdf, String fileName) async {
//     try {
//       // Get directory for saving PDF
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/$fileName');

//       // Save PDF
//       await file.writeAsBytes(await pdf.save());

//       // Open PDF
//       final result = await OpenFile.open(file.path);
//       if (result.type != ResultType.done) {
//         throw Exception('Could not open PDF file');
//       }
//     } catch (e) {
//       throw Exception('Failed to save/open PDF: $e');
//     }
//   }
// }


import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../models/job_cost_report_models.dart';

class JobCostPdfService {
  static final currencyFormat = NumberFormat('#,##0.00', 'en_US');
  static final dateFormat = DateFormat('dd MMM yyyy');

  // A4 width minus margins (595.28 - 80 = 515.28)
  static const double pageWidth = 515.28;

  // Brand Colors
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF1565C0);
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFF42A5F5);
  static const PdfColor accentColor = PdfColor.fromInt(0xFFFF6F00);
  static const PdfColor successColor = PdfColor.fromInt(0xFF2E7D32);
  static const PdfColor dangerColor = PdfColor.fromInt(0xFFC62828);
  static const PdfColor lightGray = PdfColor.fromInt(0xFFF5F5F5);
  static const PdfColor darkGray = PdfColor.fromInt(0xFF616161);

  static Future<Uint8List> generateReport(JobCostReportData data) async {
    final pdf = pw.Document();

    final ttfRegular = pw.Font.helvetica();
    final ttfBold = pw.Font.helveticaBold();
    final ttfItalic = pw.Font.helveticaOblique();

    Uint8List? logoBytes;
    try {
      final logoData = await rootBundle.load(
        'assets/images/immense_home_logo.png',
      );
      logoBytes = logoData.buffer.asUint8List();
    } catch (e) {
      print('Logo not found: $e');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(context, logoBytes, ttfBold, ttfRegular),
        footer: (context) => _buildFooter(context, ttfRegular, ttfItalic),
        build: (context) => [
          _buildJobInfoSection(data, ttfBold, ttfRegular),
          pw.SizedBox(height: 20),
          _buildCustomerSection(data, ttfBold, ttfRegular),
          pw.SizedBox(height: 20),
          _buildMaterialCostTable(data, ttfBold, ttfRegular),
          pw.SizedBox(height: 20),
          if (data.laborCosts.isNotEmpty) ...[
            _buildLaborCostTable(data, ttfBold, ttfRegular),
            pw.SizedBox(height: 20),
          ],
          if (data.additionalCosts.isNotEmpty) ...[
            _buildAdditionalCostTable(data, ttfBold, ttfRegular),
            pw.SizedBox(height: 20),
          ],
          _buildFinancialOverview(data, ttfBold, ttfRegular),
          pw.SizedBox(height: 30),
          _buildSignatureSection(ttfBold, ttfRegular),
        ],
      ),
    );

    return pdf.save();
  }

  // ============================================
  // HEADER - Fixed width constraints
  // ============================================
  static pw.Widget _buildHeader(
    pw.Context context,
    Uint8List? logoBytes,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Container(
      width: pageWidth,
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: primaryColor, width: 3)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 15),
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Logo Section - Fixed width
          logoBytes != null
              ? pw.Container(
                  width: 70,
                  height: 70,
                  child: pw.Image(pw.MemoryImage(logoBytes)),
                )
              : pw.Container(
                  width: 70,
                  height: 70,
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'IH',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 28,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
          pw.SizedBox(width: 15),

          // Company Details - Fixed width
          pw.SizedBox(
            width: 250,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  CompanyInfo.name,
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  CompanyInfo.tagline,
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8,
                    color: darkGray,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  CompanyInfo.address1,
                  style: pw.TextStyle(font: regularFont, fontSize: 7),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  CompanyInfo.address2,
                  style: pw.TextStyle(font: regularFont, fontSize: 7),
                ),
              ],
            ),
          ),

          // Contact Details - Fixed width
          pw.SizedBox(
            width: 160,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'JOB COST REPORT',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Tel: ${CompanyInfo.phone}',
                  style: pw.TextStyle(font: regularFont, fontSize: 7, color: darkGray),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  CompanyInfo.email,
                  style: pw.TextStyle(font: regularFont, fontSize: 6, color: darkGray),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  CompanyInfo.website,
                  style: pw.TextStyle(font: regularFont, fontSize: 7, color: primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // JOB INFO SECTION - Fixed width constraints
  // ============================================
  static pw.Widget _buildJobInfoSection(
    JobCostReportData data,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Container(
      width: pageWidth,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: lightGray,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left side - Job details (fixed width)
          pw.SizedBox(
            width: 350,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      'Job ID: ',
                      style: pw.TextStyle(font: boldFont, fontSize: 12),
                    ),
                    pw.Text(
                      data.jobId,
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 12,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    // Status Badge
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: pw.BoxDecoration(
                        color: _getStatusColor(data.status),
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      child: pw.Text(
                        data.status.displayName.toUpperCase(),
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 8,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Quotation: ${data.quotationNumber}',
                  style: pw.TextStyle(font: regularFont, fontSize: 9),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Project: ${data.projectDescription}',
                  style: pw.TextStyle(font: regularFont, fontSize: 9),
                ),
              ],
            ),
          ),
          
          // Right side - Dates (fixed width)
          pw.Container(
            width: 120,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: primaryColor),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Start Date',
                  style: pw.TextStyle(font: regularFont, fontSize: 7, color: darkGray),
                ),
                pw.Text(
                  dateFormat.format(data.startDate),
                  style: pw.TextStyle(font: boldFont, fontSize: 9),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'End Date',
                  style: pw.TextStyle(font: regularFont, fontSize: 7, color: darkGray),
                ),
                pw.Text(
                  data.endDate != null ? dateFormat.format(data.endDate!) : 'Ongoing',
                  style: pw.TextStyle(font: boldFont, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static PdfColor _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return const PdfColor.fromInt(0xFF1976D2);
      case ProjectStatus.invoiced:
        return const PdfColor.fromInt(0xFFFF9800);
      case ProjectStatus.completed:
        return const PdfColor.fromInt(0xFF4CAF50);
      case ProjectStatus.pending:
        return const PdfColor.fromInt(0xFFFFC107);
      case ProjectStatus.cancelled:
        return const PdfColor.fromInt(0xFFF44336);
    }
  }

  // ============================================
  // CUSTOMER SECTION - Fixed width constraints
  // ============================================
  static pw.Widget _buildCustomerSection(
    JobCostReportData data,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Container(
      width: pageWidth,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CUSTOMER INFORMATION',
            style: pw.TextStyle(font: boldFont, fontSize: 10, color: primaryColor),
          ),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 4),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left column
              pw.SizedBox(
                width: 300,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Name:', data.customerName, boldFont, regularFont),
                    _buildInfoRow('Address:', data.customerAddress, boldFont, regularFont),
                  ],
                ),
              ),
              // Right column
              pw.SizedBox(
                width: 180,
                child: _buildInfoRow('Phone:', data.customerPhone, boldFont, regularFont),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(
    String label,
    String value,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 50,
            child: pw.Text(label, style: pw.TextStyle(font: boldFont, fontSize: 8)),
          ),
          pw.Text(value, style: pw.TextStyle(font: regularFont, fontSize: 8)),
        ],
      ),
    );
  }

  // ============================================
  // MATERIAL COST TABLE
  // ============================================
  static pw.Widget _buildMaterialCostTable(
    JobCostReportData data,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header bar
        pw.Container(
          width: pageWidth,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: const pw.BoxDecoration(
            color: primaryColor,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(4),
              topRight: pw.Radius.circular(4),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'MATERIAL COSTS',
                style: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.white),
              ),
              if (data.hasPendingCosts)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: accentColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'PENDING COSTS',
                    style: pw.TextStyle(font: boldFont, fontSize: 7, color: PdfColors.white),
                  ),
                ),
            ],
          ),
        ),
        // Table
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FixedColumnWidth(50),
            1: const pw.FixedColumnWidth(180),
            2: const pw.FixedColumnWidth(55),
            3: const pw.FixedColumnWidth(70),
            4: const pw.FixedColumnWidth(70),
            5: const pw.FixedColumnWidth(90),
          },
          children: [
            // Header Row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: lightGray),
              children: [
                _tableHeader('Code', boldFont),
                _tableHeader('Description', boldFont),
                _tableHeader('Qty', boldFont),
                _tableHeader('Cost', boldFont),
                _tableHeader('Sell', boldFont),
                _tableHeader('Total Cost', boldFont),
              ],
            ),
            // Data Rows
            ...data.items.map((item) => pw.TableRow(
              children: [
                _tableCell(item.itemCode, regularFont),
                _tableCell(item.description, regularFont),
                _tableCell('${item.quantity} ${item.unit}', regularFont),
                _buildCostCell(item, boldFont, regularFont),
                _tableCell(currencyFormat.format(item.sellingPrice), regularFont),
                _tableCell(
                  item.isCostPending ? 'Pending' : currencyFormat.format(item.totalCost),
                  regularFont,
                  color: item.isCostPending ? accentColor : null,
                ),
              ],
            )),
            // Total Row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: lightGray),
              children: [
                _tableCell('', regularFont),
                _tableCell('', regularFont),
                _tableCell('', regularFont),
                _tableCell('', regularFont),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('TOTAL:', style: pw.TextStyle(font: boldFont, fontSize: 8), textAlign: pw.TextAlign.right),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Rs. ${currencyFormat.format(data.totalMaterialCost)}', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildCostCell(JobCostItem item, pw.Font boldFont, pw.Font regularFont) {
    if (item.isCostPending) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(3),
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: pw.BoxDecoration(
            color: accentColor,
            borderRadius: pw.BorderRadius.circular(2),
          ),
          child: pw.Text(
            'PENDING',
            style: pw.TextStyle(font: boldFont, fontSize: 6, color: PdfColors.white),
            textAlign: pw.TextAlign.center,
          ),
        ),
      );
    }
    return _tableCell(currencyFormat.format(item.costPrice), regularFont);
  }

  static pw.Widget _tableHeader(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 8), textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _tableCell(String text, pw.Font font, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 7, color: color)),
    );
  }

  // ============================================
  // LABOR COST TABLE
  // ============================================
  static pw.Widget _buildLaborCostTable(
    JobCostReportData data,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: pageWidth,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: const pw.BoxDecoration(
            color: secondaryColor,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(4),
              topRight: pw.Radius.circular(4),
            ),
          ),
          child: pw.Text(
            'LABOR COSTS',
            style: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.white),
          ),
        ),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FixedColumnWidth(180),
            1: const pw.FixedColumnWidth(120),
            2: const pw.FixedColumnWidth(50),
            3: const pw.FixedColumnWidth(80),
            4: const pw.FixedColumnWidth(85),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: lightGray),
              children: [
                _tableHeader('Description', boldFont),
                _tableHeader('Worker', boldFont),
                _tableHeader('Days', boldFont),
                _tableHeader('Daily Rate', boldFont),
                _tableHeader('Total', boldFont),
              ],
            ),
            ...data.laborCosts.map((labor) => pw.TableRow(
              children: [
                _tableCell(labor.description, regularFont),
                _tableCell(labor.workerName, regularFont),
                _tableCell(labor.days.toString(), regularFont),
                _tableCell(currencyFormat.format(labor.dailyRate), regularFont),
                _tableCell(currencyFormat.format(labor.totalCost), regularFont),
              ],
            )),
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: lightGray),
              children: [
                _tableCell('', regularFont),
                _tableCell('', regularFont),
                _tableCell('', regularFont),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('TOTAL:', style: pw.TextStyle(font: boldFont, fontSize: 8), textAlign: pw.TextAlign.right),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Rs. ${currencyFormat.format(data.totalLaborCost)}', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ============================================
  // ADDITIONAL COST TABLE
  // ============================================
  static pw.Widget _buildAdditionalCostTable(
    JobCostReportData data,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: pageWidth,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: const pw.BoxDecoration(
            color: accentColor,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(4),
              topRight: pw.Radius.circular(4),
            ),
          ),
          child: pw.Text(
            'ADDITIONAL COSTS (Transport, Tools, etc.)',
            style: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.white),
          ),
        ),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FixedColumnWidth(280),
            1: const pw.FixedColumnWidth(120),
            2: const pw.FixedColumnWidth(115),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: lightGray),
              children: [
                _tableHeader('Description', boldFont),
                _tableHeader('Category', boldFont),
                _tableHeader('Amount (Rs.)', boldFont),
              ],
            ),
            ...data.additionalCosts.map((cost) => pw.TableRow(
              children: [
                _tableCell(cost.description, regularFont),
                _tableCell(cost.category, regularFont),
                _tableCell(currencyFormat.format(cost.amount), regularFont),
              ],
            )),
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: lightGray),
              children: [
                _tableCell('', regularFont),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('TOTAL:', style: pw.TextStyle(font: boldFont, fontSize: 8), textAlign: pw.TextAlign.right),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Rs. ${currencyFormat.format(data.totalAdditionalCost)}', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ============================================
  // FINANCIAL OVERVIEW - Fixed width constraints
  // ============================================
  static pw.Widget _buildFinancialOverview(
    JobCostReportData data,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    final isProfit = data.netProfit >= 0;

    return pw.Container(
      width: pageWidth,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: primaryColor, width: 2),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'FINANCIAL OVERVIEW',
            style: pw.TextStyle(font: boldFont, fontSize: 12, color: primaryColor),
          ),
          pw.Divider(color: primaryColor),
          pw.SizedBox(height: 8),
          
          // Two columns with fixed widths
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cost Summary - Fixed width
              pw.SizedBox(
                width: 230,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _financialRow('Material Cost:', 'Rs. ${currencyFormat.format(data.totalMaterialCost)}', boldFont, regularFont),
                    _financialRow('Labor Cost:', 'Rs. ${currencyFormat.format(data.totalLaborCost)}', boldFont, regularFont),
                    _financialRow('Additional Cost:', 'Rs. ${currencyFormat.format(data.totalAdditionalCost)}', boldFont, regularFont),
                    pw.Divider(),
                    _financialRow('TOTAL COST:', 'Rs. ${currencyFormat.format(data.totalCost)}', boldFont, regularFont, isTotal: true),
                  ],
                ),
              ),
              
              // Divider
              pw.Container(width: 1, height: 80, color: PdfColors.grey300, margin: const pw.EdgeInsets.symmetric(horizontal: 10)),
              
              // Revenue Summary - Fixed width
              pw.SizedBox(
                width: 230,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _financialRow('Total Invoiced:', 'Rs. ${currencyFormat.format(data.totalInvoiced)}', boldFont, regularFont),
                    _financialRow('Advance Received:', 'Rs. ${currencyFormat.format(data.advanceReceived)}', boldFont, regularFont),
                    _financialRow('Balance Due:', 'Rs. ${currencyFormat.format(data.totalInvoiced - data.advanceReceived)}', boldFont, regularFont),
                    pw.Divider(),
                    _financialRow('Gross Profit:', 'Rs. ${currencyFormat.format(data.grossProfit)}', boldFont, regularFont),
                  ],
                ),
              ),
            ],
          ),
          
          pw.SizedBox(height: 12),
          
          // Net Profit Box
          pw.Container(
            width: pageWidth - 24,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: isProfit ? successColor : dangerColor,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  isProfit ? 'NET PROFIT: ' : 'NET LOSS: ',
                  style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.white),
                ),
                pw.Text(
                  'Rs. ${currencyFormat.format(data.netProfit.abs())}',
                  style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.white),
                ),
                pw.SizedBox(width: 15),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Text(
                    '${data.profitMargin.toStringAsFixed(1)}%',
                    style: pw.TextStyle(font: boldFont, fontSize: 10, color: isProfit ? successColor : dangerColor),
                  ),
                ),
              ],
            ),
          ),
          
          // Warning for pending costs
          if (data.hasPendingCosts)
            pw.Container(
              width: pageWidth - 24,
              margin: const pw.EdgeInsets.only(top: 8),
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFFFF3E0),
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: accentColor),
              ),
              child: pw.Row(
                children: [
                  pw.Text('WARNING: ', style: pw.TextStyle(font: boldFont, fontSize: 8, color: accentColor)),
                  pw.Text(
                    'Some items have pending cost prices. Update for accurate calculation.',
                    style: pw.TextStyle(font: regularFont, fontSize: 8, color: accentColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _financialRow(
    String label,
    String value,
    pw.Font boldFont,
    pw.Font regularFont, {
    bool isTotal = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: isTotal ? boldFont : regularFont, fontSize: isTotal ? 9 : 8)),
          pw.Text(value, style: pw.TextStyle(font: isTotal ? boldFont : regularFont, fontSize: isTotal ? 9 : 8)),
        ],
      ),
    );
  }

  // ============================================
  // SIGNATURE SECTION - Fixed width constraints
  // ============================================
  static pw.Widget _buildSignatureSection(pw.Font boldFont, pw.Font regularFont) {
    return pw.Container(
      width: pageWidth,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _signatureBox('Prepared By', boldFont, regularFont),
          _signatureBox('Verified By', boldFont, regularFont),
          _signatureBox('Approved By (Director)', boldFont, regularFont),
        ],
      ),
    );
  }

  static pw.Widget _signatureBox(String title, pw.Font boldFont, pw.Font regularFont) {
    return pw.SizedBox(
      width: 150,
      child: pw.Column(
        children: [
          pw.Container(
            height: 40,
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(title, style: pw.TextStyle(font: boldFont, fontSize: 8)),
          pw.Text('Date: ____________', style: pw.TextStyle(font: regularFont, fontSize: 7)),
        ],
      ),
    );
  }

  // ============================================
  // FOOTER
  // ============================================
  static pw.Widget _buildFooter(
    pw.Context context,
    pw.Font regularFont,
    pw.Font italicFont,
  ) {
    return pw.Container(
      width: pageWidth,
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: primaryColor, width: 2)),
      ),
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                style: pw.TextStyle(font: regularFont, fontSize: 7, color: darkGray),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(font: regularFont, fontSize: 7, color: darkGray),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Computer generated document. Contact: ${CompanyInfo.email}',
            style: pw.TextStyle(font: italicFont, fontSize: 6, color: darkGray),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '${DateTime.now().year} ${CompanyInfo.name}. All Rights Reserved.',
            style: pw.TextStyle(font: regularFont, fontSize: 6, color: darkGray),
          ),
        ],
      ),
    );
  }

  // Save and Open PDF
  static Future<File> saveAndOpenPDF(Uint8List bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);

    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      throw Exception('Could not open PDF file');
    }
    return file;
  }
}