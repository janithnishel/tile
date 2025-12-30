// Print Service
// lib/services/print_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../models/site_visits/site_visit_model.dart';

class PrintService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Company Details
  static const String companyName = 'IMMENSE HOME';
  static const String companySubtitle = 'PRIVATE LIMITED';
  static const String address1 = '157/1 Old Kottawa Road, Mirihana, Nugegoda';
  static const String address2 = 'No.23/1, Akurassa Road Nupe, Matara';
  static const String address3 = 'Colombo 81300, LK';
  static const String website = 'www.immensehome.lk';
  static const String phone = '077 586 70 80';
  static const String email = 'immensehomeprivatelimited@gmail.com';
  static const String bankDetails =
      'Immense Home (Pvt) Ltd - Hatton National Bank, A/C No. 200010008304';

  // Generate PDF Document
  static Future<pw.Document> generateInvoicePdf(SiteVisitModel visit) async {
    final pdf = pw.Document();
    final dueDate = visit.date.add(const Duration(days: 7));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header with Logo
            _buildHeader(),
            pw.SizedBox(height: 20),

            // Invoice Details Row
            _buildInvoiceDetailsRow(visit, dueDate),
            pw.SizedBox(height: 20),

            // Bill To Section
            _buildBillToSection(visit),
            pw.SizedBox(height: 20),

            // Site Specifications
            _buildSiteSpecifications(visit),
            pw.SizedBox(height: 20),

            // Inspection Details
            _buildInspectionDetails(visit),
            pw.SizedBox(height: 20),

            // Service Charge Table
            _buildChargeTable(visit),
            pw.SizedBox(height: 20),

            // Total Section
            _buildTotalSection(visit),
            pw.SizedBox(height: 20),

            // Payment Instructions
            _buildPaymentInstructions(),
            pw.SizedBox(height: 15),

            // Banking Details
            _buildBankingDetails(),
            pw.SizedBox(height: 30),

            // Signatures
            _buildSignatures(),
          ];
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Logo
            pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                color: PdfColors.orange,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Center(
                child: pw.Text(
                  'IH',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.SizedBox(width: 15),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  companyName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.Text(
                  companySubtitle,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(address1,
                    style:
                        const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                pw.Text(address2,
                    style:
                        const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                pw.Text(address3,
                    style:
                        const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
              ],
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(website,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
            pw.Text(phone,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
            pw.Text(email,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceDetailsRow(SiteVisitModel visit, DateTime dueDate) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SITE VISIT INVOICE',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Invoice #: ${visit.id}',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Date: ${_dateFormat.format(visit.date)}',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
              ),
              pw.Text(
                'Due: ${_dateFormat.format(dueDate)}',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBillToSection(SiteVisitModel visit) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.purple200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BILL TO',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            visit.customerName,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text('Phone: ',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey600)),
              pw.Text(visit.contactNo,
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey800)),
            ],
          ),
          pw.Row(
            children: [
              pw.Text('Location: ',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey600)),
              pw.Expanded(
                child: pw.Text(visit.location,
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey800)),
              ),
            ],
          ),
          if (visit.projectTitle.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              children: [
                pw.Text('Project: ',
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey600)),
                pw.Text(visit.projectTitle,
                    style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey800,
                        fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildSiteSpecifications(SiteVisitModel visit) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SITE SPECIFICATIONS',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSpecItem('Color Code', visit.colorCode),
              _buildSpecItem('Thickness', visit.thickness),
              _buildSpecItem('Site Type', visit.siteType),
            ],
          ),
          pw.SizedBox(height: 10),
          if (visit.floorCondition.isNotEmpty) ...[
            pw.Text('Floor Condition:',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700)),
            pw.SizedBox(height: 5),
            pw.Wrap(
              spacing: 5,
              runSpacing: 5,
              children: visit.floorCondition
                  .map((condition) => _buildTag(condition, PdfColors.green))
                  .toList(),
            ),
          ],
          if (visit.targetArea.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text('Target Areas:',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700)),
            pw.SizedBox(height: 5),
            pw.Wrap(
              spacing: 5,
              runSpacing: 5,
              children: visit.targetArea
                  .map((area) => _buildTag(area, PdfColors.blue))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildSpecItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.Text(value.isNotEmpty ? value : 'N/A',
            style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800)),
      ],
    );
  }

  static pw.Widget _buildTag(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: color.shade(50),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: color),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          color: color.shade(800),
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildInspectionDetails(SiteVisitModel visit) {
    final inspectionItems = [
      {'label': 'Skirting', 'value': visit.inspection.skirting},
      {'label': 'Floor Preparation', 'value': visit.inspection.floorPreparation},
      {'label': 'Ground Setting', 'value': visit.inspection.groundSetting},
      {'label': 'Door Clearance', 'value': visit.inspection.door},
      {'label': 'Window', 'value': visit.inspection.window},
      {'label': 'Surface Level', 'value': visit.inspection.evenUneven},
      {'label': 'Overall Condition', 'value': visit.inspection.areaCondition},
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'INSPECTION DETAILS',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Inspection Item',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Observation',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
            ...inspectionItems.map((item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['label']!,
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                          item['value']!.isNotEmpty ? item['value']! : 'N/A',
                          style: const pw.TextStyle(fontSize: 9)),
                    ),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildChargeTable(SiteVisitModel visit) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.purple100),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text('Item',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text('Qty',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text('Price',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text('Amount',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text('Site Visiting Service',
                  style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text('1',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text('LKR ${visit.charge.toStringAsFixed(2)}',
                  textAlign: pw.TextAlign.right,
                  style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text('LKR ${visit.charge.toStringAsFixed(2)}',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTotalSection(SiteVisitModel visit) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 200,
          child: pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:',
                      style: pw.TextStyle(
                          fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text('LKR ${visit.charge.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.purple,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL:',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                    pw.Text('LKR ${visit.charge.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPaymentInstructions() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.yellow200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Payment Instructions',
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800)),
          pw.SizedBox(height: 8),
          pw.Bullet(
            text:
                'If you agreed, work commencement will proceed soon after receiving 75% of the quotation amount.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.Bullet(
            text:
                'It is essential to pay the amount remaining after the completion of work.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.Bullet(
            text:
                'Please deposit cash/fund transfer/cheque payments to the following account.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBankingDetails() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Banking Details:',
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800)),
          pw.SizedBox(height: 5),
          pw.Text('Immense Home (Pvt) Ltd',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.Text('Hatton National Bank, A/C No. 200010008304',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatures() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'By signing this document, the customer agrees to the services and conditions described in this document.',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 30),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 150,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.grey400)),
                  ),
                  child: pw.SizedBox(height: 40),
                ),
                pw.SizedBox(height: 5),
                pw.Text('Customer Signature',
                    style:
                        const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                pw.Text('(     /     /     )',
                    style:
                        const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 150,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.grey400)),
                  ),
                  child: pw.SizedBox(height: 40),
                ),
                pw.SizedBox(height: 5),
                pw.Text('Authorized Signature',
                    style:
                        const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                pw.Text('(     /     /     )',
                    style:
                        const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Print Invoice
  static Future<void> printInvoice(SiteVisitModel visit) async {
    final pdf = await generateInvoicePdf(visit);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'SiteVisit_${visit.id}',
    );
  }

  // Preview Invoice
  static Future<void> previewInvoice(
      BuildContext context, SiteVisitModel visit) async {
    final pdf = await generateInvoicePdf(visit);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Invoice Preview - ${visit.id}'),
            backgroundColor: Colors.purple.shade700,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: () => printInvoice(visit),
                tooltip: 'Print',
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  await Printing.sharePdf(
                    bytes: await pdf.save(),
                    filename: 'SiteVisit_${visit.id}.pdf',
                  );
                },
                tooltip: 'Share',
              ),
            ],
          ),
          body: PdfPreview(
            build: (format) => pdf.save(),
            allowPrinting: true,
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
            pdfFileName: 'SiteVisit_${visit.id}.pdf',
          ),
        ),
      ),
    );
  }

  // Save PDF to device
  static Future<String?> savePDF(SiteVisitModel visit) async {
    try {
      final pdf = await generateInvoicePdf(visit);
      final bytes = await pdf.save();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/SiteVisit_${visit.id}.pdf');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  // Share Invoice
  static Future<void> shareInvoice(SiteVisitModel visit) async {
    final pdf = await generateInvoicePdf(visit);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'SiteVisit_${visit.id}.pdf',
    );
  }
}
