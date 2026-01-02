import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';

// ============================================
// COMPANY INFO - Centralized
// ============================================
class CompanyInfo {
  static const String name = 'IMMENSE HOME (PVT) LTD';
  static const String tagline = 'Your Trusted Flooring Partner';
  static const String address1 = '157/1 Old Kottawa Road, Mirihana';
  static const String address2 = 'Nugegoda, Colombo 81300';
  static const String phone = '077 586 70 80';
  static const String email = 'immensehomeprivatelimited@gmail.com';
  static const String website = 'www.immensehome.lk';
  static const String bankName = 'Hatton National Bank';
  static const String accountNo = '200010008304';
  static const String accountName = 'Immense Home (Pvt) Ltd';
}

// ============================================
// GROUPED ITEM MODEL
// ============================================
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

// STATUS BADGE INFO HELPER CLASS
class _StatusBadgeInfo {
  final PdfColor color;
  final PdfColor borderColor;

  _StatusBadgeInfo(this.color, this.borderColor);
}

// ============================================
// PDF SERVICE CLASS
// ============================================
class DocumentPdfService {
  // Currency & Date Formatters
  static final currencyFormat = NumberFormat('#,##0.00', 'en_US');
  static final dateFormat = DateFormat('dd MMM yyyy');
  static final dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  // Page dimensions (A4 width minus margins)
  static const double pageWidth = 515.28;

  // Brand Colors - Quotation (Blue)
  static const PdfColor quotationPrimary = PdfColor.fromInt(0xFF1E88E5);
  static const PdfColor quotationDark = PdfColor.fromInt(0xFF1565C0);
  static const PdfColor quotationLight = PdfColor.fromInt(0xFFE3F2FD);

  // Brand Colors - Invoice (Green)
  static const PdfColor invoicePrimary = PdfColor.fromInt(0xFF43A047);
  static const PdfColor invoiceDark = PdfColor.fromInt(0xFF2E7D32);
  static const PdfColor invoiceLight = PdfColor.fromInt(0xFFE8F5E9);

  // Common Colors
  static const PdfColor successColor = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor dangerColor = PdfColor.fromInt(0xFFC62828);
  static const PdfColor warningColor = PdfColor.fromInt(0xFFFF9800);
  static const PdfColor lightGray = PdfColor.fromInt(0xFFF5F5F5);
  static const PdfColor darkGray = PdfColor.fromInt(0xFF616161);
  static const PdfColor accentColor = PdfColor.fromInt(0xFF263238);

  // ============================================
  // MAIN GENERATE METHOD
  // ============================================
  static Future<Uint8List> generateDocument({
    required QuotationDocument document,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String projectTitle,
    bool isPreview = false, // Show status badge in preview, hide in final PDF
  }) async {
    final pdf = pw.Document();

    // Load fonts
    final ttfRegular = pw.Font.helvetica();
    final ttfBold = pw.Font.helveticaBold();
    final ttfItalic = pw.Font.helveticaOblique();

    // Load logo
    Uint8List? logoBytes;
    try {
      final logoData = await rootBundle.load('assets/images/immense_home_logo.png');
      logoBytes = logoData.buffer.asUint8List();
    } catch (e) {
      print('Logo not found: $e');
    }

    // Determine colors based on document type
    final bool isQuotation = document.type == DocumentType.quotation;
    final PdfColor primaryColor = isQuotation ? quotationPrimary : invoicePrimary;
    final PdfColor darkColor = isQuotation ? quotationDark : invoiceDark;
    final PdfColor lightColor = isQuotation ? quotationLight : invoiceLight;
    final String title = isQuotation ? 'QUOTATION' : 'INVOICE';

    // Check if paid
    final bool isPaid = document.status == DocumentStatus.paid;

    // Group items
    final groupedItems = _groupLineItems(document);
    final deductions = _getPaidSiteVisitDeductions(document);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(
          context: context,
          logoBytes: logoBytes,
          boldFont: ttfBold,
          regularFont: ttfRegular,
          primaryColor: primaryColor,
          title: title,
        ),
        footer: (context) => _buildFooter(
          context: context,
          regularFont: ttfRegular,
          italicFont: ttfItalic,
          primaryColor: primaryColor,
        ),
        build: (context) => [
          // Document Info Bar - Show status only in preview mode
          _buildDocumentInfoBar(
            document: document,
            boldFont: ttfBold,
            regularFont: ttfRegular,
            primaryColor: primaryColor,
            title: title,
            showStatus: isPreview, // Show status badge only in preview mode
          ),
          pw.SizedBox(height: 20),

          // Customer Section with Project Title
          _buildCustomerSection(
            customerName: customerName,
            customerPhone: customerPhone,
            customerAddress: customerAddress,
            projectTitle: projectTitle,
            boldFont: ttfBold,
            regularFont: ttfRegular,
            primaryColor: primaryColor,
          ),
          pw.SizedBox(height: 20),

          // Items Table
          _buildItemsTable(
            groupedItems: groupedItems,
            deductions: deductions,
            document: document,
            boldFont: ttfBold,
            regularFont: ttfRegular,
            primaryColor: primaryColor,
          ),
          pw.SizedBox(height: 20),

          // Total Section
          _buildTotalSection(
            document: document,
            boldFont: ttfBold,
            regularFont: ttfRegular,
            primaryColor: primaryColor,
            isQuotation: isQuotation,
          ),
          pw.SizedBox(height: 25),

          // Payment Instructions - HIDE WHEN PAID
          if (!isPaid) ...[
            _buildPaymentInstructions(
              document: document,
              boldFont: ttfBold,
              regularFont: ttfRegular,
            ),
            pw.SizedBox(height: 20),
          ],

          // Terms & Conditions
          _buildTermsAndConditions(
            boldFont: ttfBold,
            regularFont: ttfRegular,
            isQuotation: isQuotation,
          ),
          pw.SizedBox(height: 25),

          // Signature Section
          _buildSignatureSection(
            customerName: customerName,
            boldFont: ttfBold,
            regularFont: ttfRegular,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ============================================
  // HEADER SECTION - FIXED ICONS
  // ============================================
  static pw.Widget _buildHeader({
    required pw.Context context,
    required Uint8List? logoBytes,
    required pw.Font boldFont,
    required pw.Font regularFont,
    required PdfColor primaryColor,
    required String title,
  }) {
    return pw.Container(
      width: pageWidth,
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: primaryColor, width: 3)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 15),
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Logo
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

          // Company Details - FIXED: Removed emoji icons
          pw.SizedBox(
            width: 250,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'IMMENSE HOME',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 18,
                    color: primaryColor,
                  ),
                ),
                pw.Text(
                  'PRIVATE LIMITED',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 10,
                    color: accentColor,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 8),
                _buildHeaderContactRow('Address:', CompanyInfo.address1, regularFont, boldFont),
                _buildHeaderContactRow('', CompanyInfo.address2, regularFont, boldFont),
                _buildHeaderContactRow('Tel:', CompanyInfo.phone, regularFont, boldFont),
                _buildHeaderContactRow('Web:', CompanyInfo.website, regularFont, boldFont),
              ],
            ),
          ),

          // Document Badge
          pw.SizedBox(
            width: 160,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    title,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 16,
                      color: PdfColors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Tel: ${CompanyInfo.phone}',
                  style: pw.TextStyle(font: regularFont, fontSize: 8, color: darkGray),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  CompanyInfo.email,
                  style: pw.TextStyle(font: regularFont, fontSize: 7, color: darkGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Header contact row without emoji
  static pw.Widget _buildHeaderContactRow(String label, String text, pw.Font regularFont, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: [
          if (label.isNotEmpty)
            pw.Text(
              label,
              style: pw.TextStyle(font: boldFont, fontSize: 7, color: darkGray),
            ),
          if (label.isNotEmpty) pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(font: regularFont, fontSize: 8, color: darkGray),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // DOCUMENT INFO BAR - CONDITIONAL STATUS DISPLAY
  // ============================================
  static pw.Widget _buildDocumentInfoBar({
    required QuotationDocument document,
    required pw.Font boldFont,
    required pw.Font regularFont,
    required PdfColor primaryColor,
    required String title,
    bool showStatus = false, // Show status only in preview mode
  }) {
    return pw.Container(
      width: pageWidth,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: lightGray,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Document Number with optional Status Badge
          pw.Row(
            children: [
              pw.Text(
                '$title #: ',
                style: pw.TextStyle(font: regularFont, fontSize: 10),
              ),
              pw.Text(
                document.displayDocumentNumber,
                style: pw.TextStyle(font: boldFont, fontSize: 12, color: primaryColor),
              ),
              if (showStatus) ...[
                pw.SizedBox(width: 8),
                _buildStatusBadge(document.status, boldFont, regularFont),
              ],
            ],
          ),

          // Dates
          pw.Row(
            children: [
              _buildDateBox('Issue Date', dateFormat.format(document.invoiceDate), boldFont, regularFont),
              pw.SizedBox(width: 15),
              _buildDateBox('Due Date', dateFormat.format(document.dueDate), boldFont, regularFont),
              pw.SizedBox(width: 15),
              _buildDateBox('Terms', '${document.paymentTerms} Days', boldFont, regularFont),
            ],
          ),
        ],
      ),
    );
  }

  // STATUS BADGE FOR PDF
  static pw.Widget _buildStatusBadge(DocumentStatus status, pw.Font boldFont, pw.Font regularFont) {
    final statusInfo = _getStatusBadgeInfo(status);

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: statusInfo.color,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: statusInfo.borderColor),
      ),
      child: pw.Text(
        status.name.toUpperCase(),
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 8,
          color: PdfColors.white,
        ),
      ),
    );
  }

  // STATUS BADGE INFO HELPER
  static _StatusBadgeInfo _getStatusBadgeInfo(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return _StatusBadgeInfo(PdfColor.fromInt(0xFFFF9800), PdfColor.fromInt(0xFFE65100)); // Orange
      case DocumentStatus.approved:
        return _StatusBadgeInfo(PdfColor.fromInt(0xFF2196F3), PdfColor.fromInt(0xFF0D47A1)); // Blue
      case DocumentStatus.partial:
        return _StatusBadgeInfo(PdfColor.fromInt(0xFFFF5722), PdfColor.fromInt(0xFFD84315)); // Red
      case DocumentStatus.paid:
        return _StatusBadgeInfo(PdfColor.fromInt(0xFF4CAF50), PdfColor.fromInt(0xFF2E7D32)); // Green
      case DocumentStatus.rejected:
        return _StatusBadgeInfo(PdfColor.fromInt(0xFFC62828), PdfColor.fromInt(0xFFAD1457)); // Red
      case DocumentStatus.converted:
        return _StatusBadgeInfo(PdfColor.fromInt(0xFF9C27B0), PdfColor.fromInt(0xFF7B1FA2)); // Purple
      case DocumentStatus.invoiced:
        return _StatusBadgeInfo(PdfColor.fromInt(0xFF009688), PdfColor.fromInt(0xFF00695C)); // Teal
    }
  }

  static pw.Widget _buildDateBox(String label, String value, pw.Font boldFont, pw.Font regularFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: pw.TextStyle(font: regularFont, fontSize: 7, color: darkGray)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 9)),
      ],
    );
  }

  // ============================================
  // CUSTOMER SECTION - FIXED PROJECT NAME DISPLAY
  // ============================================
  static pw.Widget _buildCustomerSection({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String projectTitle,
    required pw.Font boldFont,
    required pw.Font regularFont,
    required PdfColor primaryColor,
  }) {
    return pw.Container(
      width: pageWidth,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header Row - FIXED: Removed emoji
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: primaryColor.shade(0.9),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'BILL TO',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 8,
                    color: primaryColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          pw.Divider(color: PdfColors.grey300, height: 20),
          
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Customer Details
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Customer Name
                    pw.Text(
                      customerName.isEmpty ? 'N/A' : customerName,
                      style: pw.TextStyle(font: boldFont, fontSize: 14, color: accentColor),
                    ),
                    
                    // FIXED: Project Title - Improved visibility
                    if (projectTitle.isNotEmpty) ...[
                      pw.SizedBox(height: 8),
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: primaryColor.shade(0.85),
                          borderRadius: pw.BorderRadius.circular(6),
                          border: pw.Border.all(color: primaryColor, width: 1),
                        ),
                        child: pw.Row(
                          children: [
                            pw.Text(
                              'PROJECT: ',
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 9,
                                color: primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                projectTitle,
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 10,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    pw.SizedBox(height: 8),
                    
                    // Address - FIXED: Removed emoji
                    if (customerAddress.isNotEmpty)
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Address: ',
                            style: pw.TextStyle(font: boldFont, fontSize: 8, color: darkGray),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              customerAddress,
                              style: pw.TextStyle(font: regularFont, fontSize: 9, color: darkGray),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              pw.SizedBox(width: 15),

              // Contact Info
              pw.SizedBox(
                width: 130,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (customerPhone.isNotEmpty)
                      pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: primaryColor),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'CONTACT',
                              style: pw.TextStyle(font: boldFont, fontSize: 7, color: darkGray, letterSpacing: 1),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              customerPhone,
                              style: pw.TextStyle(font: boldFont, fontSize: 11, color: primaryColor),
                            ),
                          ],
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

  // ============================================
  // ITEMS TABLE - FIXED ICONS
  // ============================================
  static pw.Widget _buildItemsTable({
    required List<_GroupedItem> groupedItems,
    required List<_DeductionItem> deductions,
    required QuotationDocument document,
    required pw.Font boldFont,
    required pw.Font regularFont,
    required PdfColor primaryColor,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header Bar
        pw.Container(
          width: pageWidth,
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: pw.BoxDecoration(
            color: primaryColor,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Text(
            'ITEMS & SERVICES',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 11,
              color: PdfColors.white,
              letterSpacing: 1,
            ),
          ),
        ),

        // Table
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FixedColumnWidth(200), // Description
            1: const pw.FixedColumnWidth(60),  // Qty
            2: const pw.FixedColumnWidth(45),  // Unit
            3: const pw.FixedColumnWidth(90),  // Rate
            4: const pw.FixedColumnWidth(120), // Amount
          },
          children: [
            // Header Row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: lightGray),
              children: [
                _tableHeader('Description', boldFont),
                _tableHeader('Qty', boldFont),
                _tableHeader('Unit', boldFont),
                _tableHeader('Rate (Rs.)', boldFont),
                _tableHeader('Amount (Rs.)', boldFont),
              ],
            ),

            // Item Rows
            ...groupedItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isEven = index % 2 == 0;
              
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: isEven ? PdfColors.white : lightGray,
                ),
                children: [
                  _tableCell(item.description, regularFont, boldFont, isDescription: true),
                  _tableCell(item.quantity.toStringAsFixed(1), regularFont, boldFont, align: pw.TextAlign.center),
                  _tableCell(item.unit, regularFont, boldFont, align: pw.TextAlign.center),
                  _tableCell(currencyFormat.format(item.price), regularFont, boldFont, align: pw.TextAlign.right),
                  _tableCell(currencyFormat.format(item.amount), regularFont, boldFont, align: pw.TextAlign.right, isBold: true),
                ],
              );
            }),

            // Service Items
            ...document.serviceItems.map((service) {
              final displayAmount = service.isAlreadyPaid ? -service.amount : service.amount;
              final isDeduction = service.isAlreadyPaid;

              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: isDeduction ? PdfColor.fromInt(0xFFFFEBEE) : PdfColor.fromInt(0xFFE3F2FD),
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          service.serviceDescription,
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 9,
                            color: isDeduction ? dangerColor : accentColor,
                          ),
                        ),
                        if (isDeduction)
                          pw.Text(
                            'Already Paid - Deducted',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 7,
                              color: dangerColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _tableCell(service.quantity.toStringAsFixed(1), regularFont, boldFont, align: pw.TextAlign.center),
                  _tableCell(service.unitTypeDisplay, regularFont, boldFont, align: pw.TextAlign.center),
                  _tableCell(currencyFormat.format(service.rate), regularFont, boldFont, align: pw.TextAlign.right),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      '${displayAmount >= 0 ? '' : '-'}${currencyFormat.format(displayAmount.abs())}',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 9,
                        color: isDeduction ? dangerColor : accentColor,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              );
            }),

            // Deduction Rows
            ...deductions.map((deduction) {
              return pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFEBEE)),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      '${deduction.description} (Deduction)',
                      style: pw.TextStyle(font: boldFont, fontSize: 9, color: dangerColor),
                    ),
                  ),
                  _tableCell('-', regularFont, boldFont, align: pw.TextAlign.center),
                  _tableCell('-', regularFont, boldFont, align: pw.TextAlign.center),
                  _tableCell('-', regularFont, boldFont, align: pw.TextAlign.right),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      '-${currencyFormat.format(deduction.amount)}',
                      style: pw.TextStyle(font: boldFont, fontSize: 9, color: dangerColor),
                      textAlign: pw.TextAlign.right,
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

  static pw.Widget _tableHeader(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 9),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _tableCell(
    String text,
    pw.Font regularFont,
    pw.Font boldFont, {
    pw.TextAlign align = pw.TextAlign.left,
    bool isDescription = false,
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: isBold ? boldFont : regularFont,
          fontSize: isDescription ? 9 : 8,
        ),
        textAlign: align,
      ),
    );
  }

  // ============================================
  // TOTAL SECTION - FIXED ICONS
  // ============================================
  static pw.Widget _buildTotalSection({
    required QuotationDocument document,
    required pw.Font boldFont,
    required pw.Font regularFont,
    required PdfColor primaryColor,
    required bool isQuotation,
  }) {
    final isPaid = document.status == DocumentStatus.paid;

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 280,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: primaryColor, width: 2),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              // Subtotal
              _buildTotalRow('Subtotal', document.subtotal, boldFont, regularFont),

              // Payment History
              if (!isQuotation && document.paymentHistory.isNotEmpty) ...[
                pw.Divider(color: PdfColors.grey300, height: 1),
                ...document.paymentHistory.map((p) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: const pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFE8F5E9),
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
                                style: pw.TextStyle(font: boldFont, fontSize: 8, color: successColor),
                              ),
                              pw.Text(
                                dateFormat.format(p.date),
                                style: pw.TextStyle(font: regularFont, fontSize: 7, color: darkGray),
                              ),
                            ],
                          ),
                        ),
                        pw.Text(
                          '-Rs. ${currencyFormat.format(p.amount)}',
                          style: pw.TextStyle(font: boldFont, fontSize: 9, color: successColor),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              // Amount Due / Paid Box - FIXED: Removed emoji
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: isPaid ? successColor : primaryColor,
                  borderRadius: const pw.BorderRadius.only(
                    bottomLeft: pw.Radius.circular(6),
                    bottomRight: pw.Radius.circular(6),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      isPaid
                          ? 'PAID IN FULL'
                          : isQuotation
                              ? 'ESTIMATED TOTAL'
                              : 'AMOUNT DUE',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 11,
                        color: PdfColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    pw.Text(
                      isPaid ? 'Rs. 0.00' : 'Rs. ${currencyFormat.format(document.amountDue)}',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 14,
                        color: PdfColors.white,
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

  static pw.Widget _buildTotalRow(String label, double amount, pw.Font boldFont, pw.Font regularFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: regularFont, fontSize: 10, color: darkGray)),
          pw.Text(
            'Rs. ${currencyFormat.format(amount)}',
            style: pw.TextStyle(font: boldFont, fontSize: 11, color: accentColor),
          ),
        ],
      ),
    );
  }

  // ============================================
  // PAYMENT INSTRUCTIONS - FIXED ICONS
  // ============================================
  static pw.Widget _buildPaymentInstructions({
    required QuotationDocument document,
    required pw.Font boldFont,
    required pw.Font regularFont,
  }) {
    final showAdvanceNote = document.type == DocumentType.quotation ||
        (document.type == DocumentType.invoice && document.status != DocumentStatus.paid);

    return pw.Container(
      width: pageWidth,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFE3F2FD),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFBBDEFB)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header - FIXED: Removed emoji
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFBBDEFB),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'BANK',
                  style: pw.TextStyle(font: boldFont, fontSize: 8, color: quotationPrimary),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                'PAYMENT INSTRUCTIONS',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: quotationPrimary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          pw.Divider(color: PdfColor.fromInt(0xFFBBDEFB), height: 20),

          if (showAdvanceNote)
            _buildInstructionItem('1', 'Work commencement after receiving 75% of the quotation amount.', boldFont, regularFont),
          _buildInstructionItem('2', 'Balance payment is due upon completion of work.', boldFont, regularFont),
          _buildInstructionItem('3', 'Please deposit to the following bank account.', boldFont, regularFont),

          pw.SizedBox(height: 12),

          // Bank Details Card - FIXED: Removed emoji
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: quotationPrimary),
            ),
            child: pw.Row(
              children: [
                // Bank Icon Box
                pw.Container(
                  width: 40,
                  height: 40,
                  decoration: pw.BoxDecoration(
                    color: quotationPrimary.shade(0.9),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'HNB',
                      style: pw.TextStyle(font: boldFont, fontSize: 10, color: quotationPrimary),
                    ),
                  ),
                ),
                pw.SizedBox(width: 15),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bank Details', style: pw.TextStyle(font: regularFont, fontSize: 8, color: darkGray)),
                      pw.SizedBox(height: 4),
                      pw.Text(CompanyInfo.accountName, style: pw.TextStyle(font: boldFont, fontSize: 11)),
                      pw.Text(CompanyInfo.bankName, style: pw.TextStyle(font: regularFont, fontSize: 10)),
                      pw.Text(
                        'A/C No: ${CompanyInfo.accountNo}',
                        style: pw.TextStyle(font: boldFont, fontSize: 11, color: quotationPrimary),
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

  static pw.Widget _buildInstructionItem(String number, String text, pw.Font boldFont, pw.Font regularFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 18,
            height: 18,
            decoration: pw.BoxDecoration(
              color: quotationPrimary,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                number,
                style: pw.TextStyle(font: boldFont, fontSize: 9, color: PdfColors.white),
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(font: regularFont, fontSize: 9, color: darkGray),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // TERMS & CONDITIONS - FIXED ICONS
  // ============================================
  static pw.Widget _buildTermsAndConditions({
    required pw.Font boldFont,
    required pw.Font regularFont,
    required bool isQuotation,
  }) {
    return pw.Container(
      width: pageWidth,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: lightGray,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header - FIXED: Removed emoji
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'T&C',
                  style: pw.TextStyle(font: boldFont, fontSize: 8, color: darkGray),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                'TERMS & CONDITIONS',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: darkGray,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          pw.Divider(color: PdfColors.grey300, height: 20),
          pw.Text(
            '* All prices are in Sri Lankan Rupees (LKR)\n'
            '${isQuotation ? "* This quotation is valid for 30 days from the date of issue\n" : ""}'
            '* Payment terms: 75% advance, balance upon completion\n'
            '* Work will commence within 3-5 business days after advance payment\n'
            '* Any additional work beyond the scope will be charged separately\n'
            '* Warranty: 1 year for workmanship, manufacturer warranty for materials',
            style: pw.TextStyle(font: regularFont, fontSize: 8, color: darkGray, lineSpacing: 1.5),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SIGNATURE SECTION
  // ============================================
  static pw.Widget _buildSignatureSection({
    required String customerName,
    required pw.Font boldFont,
    required pw.Font regularFont,
  }) {
    return pw.Container(
      width: pageWidth,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'By signing this document, the customer agrees to the services and conditions described above.',
            style: pw.TextStyle(font: regularFont, fontSize: 8, color: darkGray, fontStyle: pw.FontStyle.italic),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _signatureBox(
                customerName.isEmpty ? 'Customer' : customerName,
                'Customer Signature & Date',
                boldFont,
                regularFont,
              ),
              _signatureBox(
                CompanyInfo.name,
                'Authorized Signature',
                boldFont,
                regularFont,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _signatureBox(String name, String label, pw.Font boldFont, pw.Font regularFont) {
    return pw.SizedBox(
      width: 220,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            height: 50,
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 1.5)),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(name, style: pw.TextStyle(font: boldFont, fontSize: 10, color: accentColor)),
          pw.Text(label, style: pw.TextStyle(font: regularFont, fontSize: 8, color: darkGray)),
        ],
      ),
    );
  }

  // ============================================
  // FOOTER - FIXED ICONS
  // ============================================
  static pw.Widget _buildFooter({
    required pw.Context context,
    required pw.Font regularFont,
    required pw.Font italicFont,
    required PdfColor primaryColor,
  }) {
    return pw.Container(
      width: pageWidth,
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: primaryColor, width: 2)),
      ),
      padding: const pw.EdgeInsets.only(top: 10),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated: ${dateTimeFormat.format(DateTime.now())}',
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
            'Computer generated document. No signature required.',
            style: pw.TextStyle(font: italicFont, fontSize: 7, color: darkGray),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            '${DateTime.now().year} ${CompanyInfo.name}. All Rights Reserved.',
            style: pw.TextStyle(font: regularFont, fontSize: 6, color: darkGray),
          ),
        ],
      ),
    );
  }

  // ============================================
  // HELPER METHODS
  // ============================================
  static List<_GroupedItem> _groupLineItems(QuotationDocument document) {
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
        description = items[0].displayName;
      } else {
        final baseName = entry.key.replaceAll('lvt', 'LVT').replaceAll('tile', 'Tile').trim();
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

  static List<_DeductionItem> _getPaidSiteVisitDeductions(QuotationDocument document) {
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

  // ============================================
  // SAVE & OPEN PDF - NO SHARE
  // ============================================
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

  // Print PDF - Keep this for printing functionality
  static Future<void> printPDF(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  // ============================================
  // PREVIEW PDF - WITHOUT SHARE BUTTON
  // ============================================
  static Future<void> previewPDF({
    required BuildContext context,
    required QuotationDocument document,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String projectTitle,
  }) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(document.type == DocumentType.quotation ? 'Quotation Preview' : 'Invoice Preview'),
            backgroundColor: document.type == DocumentType.quotation
                ? const Color(0xFF1E88E5)
                : const Color(0xFF43A047),
            foregroundColor: Colors.white,
            actions: [
              // Only Print and Download buttons - NO SHARE
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: () async {
                  final bytes = await generateDocument(
                    document: document,
                    customerName: customerName,
                    customerPhone: customerPhone,
                    customerAddress: customerAddress,
                    projectTitle: projectTitle,
                  );
                  await printPDF(bytes);
                },
                tooltip: 'Print',
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  final bytes = await generateDocument(
                    document: document,
                    customerName: customerName,
                    customerPhone: customerPhone,
                    customerAddress: customerAddress,
                    projectTitle: projectTitle,
                  );
                  final fileName = '${document.type == DocumentType.quotation ? 'Quotation' : 'Invoice'}_${document.displayDocumentNumber}.pdf';
                  await saveAndOpenPDF(bytes, fileName);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF saved: $fileName')),
                    );
                  }
                },
                tooltip: 'Download',
              ),
            ],
          ),
          body: PdfPreview(
            build: (format) => generateDocument(
              document: document,
              customerName: customerName,
              customerPhone: customerPhone,
              customerAddress: customerAddress,
              projectTitle: projectTitle,
              isPreview: true,
            ),
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            allowPrinting: false, // Disable built-in print (we have custom button)
            allowSharing: false,  // DISABLED: Share button removed
            pdfFileName: '${document.type == DocumentType.quotation ? 'Quotation' : 'Invoice'}_${document.displayDocumentNumber}.pdf',
          ),
        ),
      ),
    );
  }
}

// ============================================
// DOCUMENT PREVIEW DIALOG WIDGET
// ============================================
class DocumentPreviewDialog extends StatefulWidget {
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
    this.customerAddress = '',
    this.projectTitle = '',
  }) : super(key: key);

  @override
  State<DocumentPreviewDialog> createState() => _DocumentPreviewDialogState();
}

class _DocumentPreviewDialogState extends State<DocumentPreviewDialog> {
  bool _isOperationRunning = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.document.type == DocumentType.quotation
                      ? [Colors.blue.shade500, Colors.blue.shade700]
                      : [Colors.green.shade500, Colors.green.shade700],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.document.type == DocumentType.quotation
                        ? Icons.description
                        : Icons.receipt_long,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.document.type == DocumentType.quotation ? 'Quotation' : 'Invoice'} Options',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.document.displayDocumentNumber,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isOperationRunning ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose an action for ${widget.document.type == DocumentType.quotation ? 'quotation' : 'invoice'} ${widget.document.displayDocumentNumber}:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButton(
                    icon: Icons.visibility,
                    label: 'View Full Preview',
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.pop(context); // Close dialog first
                      DocumentPdfService.previewPDF(
                        context: context,
                        document: widget.document,
                        customerName: widget.customerName,
                        customerPhone: widget.customerPhone,
                        customerAddress: widget.customerAddress,
                        projectTitle: widget.projectTitle,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildActionButton(
                    icon: Icons.print,
                    label: 'Print Document',
                    color: Colors.teal,
                    onPressed: () async {
                      if (_isOperationRunning) return;

                      setState(() => _isOperationRunning = true);
                      try {
                        final bytes = await DocumentPdfService.generateDocument(
                          document: widget.document,
                          customerName: widget.customerName,
                          customerPhone: widget.customerPhone,
                          customerAddress: widget.customerAddress,
                          projectTitle: widget.projectTitle,
                        );
                        await DocumentPdfService.printPDF(bytes);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Print failed: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isOperationRunning = false);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildActionButton(
                    icon: Icons.download,
                    label: 'Download PDF',
                    color: Colors.green,
                    onPressed: () async {
                      if (_isOperationRunning) return;

                      setState(() => _isOperationRunning = true);
                      try {
                        final bytes = await DocumentPdfService.generateDocument(
                          document: widget.document,
                          customerName: widget.customerName,
                          customerPhone: widget.customerPhone,
                          customerAddress: widget.customerAddress,
                          projectTitle: widget.projectTitle,
                        );
                        final fileName = '${widget.document.type == DocumentType.quotation ? 'Quotation' : 'Invoice'}_${widget.document.displayDocumentNumber}.pdf';
                        await DocumentPdfService.saveAndOpenPDF(bytes, fileName);

                        // Use addPostFrameCallback to avoid navigator lock issues
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('PDF saved: $fileName')),
                            );
                          }
                        });
                      } catch (e) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Download failed: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        });
                      } finally {
                        if (mounted) {
                          setState(() => _isOperationRunning = false);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isOperationRunning ? null : () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isOperationRunning ? null : onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
