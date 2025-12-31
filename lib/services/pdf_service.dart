import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/job_cost_screen/job_cost_document.dart';
import '../utils/job_cost_formatters.dart';

class PDFService {
  static Future<void> generateJobCostReport(JobCostDocument job) async {
    final pdf = pw.Document();

    // Use default fonts
    final font = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(boldFont),
          pw.SizedBox(height: 20),

          // Project Summary
          _buildProjectSummary(job, boldFont, font),
          pw.SizedBox(height: 20),

          // Financial Overview
          _buildFinancialOverview(job, boldFont, font),
          pw.SizedBox(height: 30),

          // Material Breakdown
          _buildMaterialBreakdown(job, boldFont, font),
          pw.SizedBox(height: 20),

          // Purchase Orders
          _buildPurchaseOrders(job, boldFont, font),
          pw.SizedBox(height: 20),

          // Other Expenses
          _buildOtherExpenses(job, boldFont, font),
        ],
      ),
    );

    // Save and open PDF
    await _saveAndOpenPDF(pdf, 'Job_Cost_Report_${job.displayId}.pdf');
  }

  static pw.Widget _buildHeader(pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'TileWork',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 24,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Job Cost Analysis Report',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 18,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Generated on: ${DateTime.now().toString().split('.')[0]}',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildProjectSummary(JobCostDocument job, pw.Font boldFont, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Project Summary',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 14,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Customer:', style: pw.TextStyle(font: boldFont)),
                    pw.Text(job.customerName),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Project:', style: pw.TextStyle(font: boldFont)),
                    pw.Text(job.projectTitle),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Job ID:', style: pw.TextStyle(font: boldFont)),
                    pw.Text(job.displayId),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Status:', style: pw.TextStyle(font: boldFont)),
                    pw.Text('Active'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFinancialOverview(JobCostDocument job, pw.Font boldFont, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Financial Overview',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 14,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Category', style: pw.TextStyle(font: boldFont)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Amount', style: pw.TextStyle(font: boldFont)),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Total Revenue'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(AppFormatters.formatCurrency(job.totalRevenue)),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Material Cost'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(AppFormatters.formatCurrency(job.materialCost)),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Purchase Order Cost'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(AppFormatters.formatCurrency(job.purchaseOrderCost)),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Other Expenses'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(AppFormatters.formatCurrency(job.otherExpensesCost)),
                  ),
                ],
              ),
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Net Profit/Loss', style: pw.TextStyle(font: boldFont)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      AppFormatters.formatCurrency(job.profit),
                      style: pw.TextStyle(
                        font: boldFont,
                        color: job.profit >= 0 ? PdfColors.green : PdfColors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMaterialBreakdown(JobCostDocument job, pw.Font boldFont, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Material Breakdown',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 14,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Item', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Qty', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Selling Price', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Cost Price', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Profit', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  ),
                ],
              ),
              ...job.invoiceItems.map((item) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(item.name, style: pw.TextStyle(fontSize: 9)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(AppFormatters.formatQuantity(item.quantity), style: pw.TextStyle(fontSize: 9)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(AppFormatters.formatCurrency(item.sellingPrice), style: pw.TextStyle(fontSize: 9)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item.hasCostPrice ? AppFormatters.formatCurrency(item.costPrice!) : '-',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item.hasCostPrice ? AppFormatters.formatCurrency(item.profit) : '-',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: item.profit >= 0 ? PdfColors.green : PdfColors.red,
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPurchaseOrders(JobCostDocument job, pw.Font boldFont, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Purchase Orders',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 14,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 12),
          if (job.purchaseOrderItems.isEmpty)
            pw.Text('No purchase orders found.', style: pw.TextStyle(fontSize: 10))
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('PO ID', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Supplier', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Item', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Amount', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                    ),
                  ],
                ),
                ...job.purchaseOrderItems.map((poItem) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(poItem.poId, style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(poItem.supplierName, style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(poItem.itemName, style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(AppFormatters.formatCurrency(poItem.totalCost), style: pw.TextStyle(fontSize: 9)),
                    ),
                  ],
                )),
              ],
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildOtherExpenses(JobCostDocument job, pw.Font boldFont, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Other Expenses',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 14,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 12),
          if (job.otherExpenses.isEmpty)
            pw.Text('No other expenses recorded.', style: pw.TextStyle(fontSize: 10))
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Date', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Category', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Description', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Amount', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                    ),
                  ],
                ),
                ...job.otherExpenses.map((expense) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(AppFormatters.formatShortDate(expense.date), style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(expense.category, style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(expense.description, style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(AppFormatters.formatCurrency(expense.amount), style: pw.TextStyle(fontSize: 9)),
                    ),
                  ],
                )),
              ],
            ),
        ],
      ),
    );
  }

  static Future<void> _saveAndOpenPDF(pw.Document pdf, String fileName) async {
    try {
      // Get directory for saving PDF
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      // Save PDF
      await file.writeAsBytes(await pdf.save());

      // Open PDF
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        throw Exception('Could not open PDF file');
      }
    } catch (e) {
      throw Exception('Failed to save/open PDF: $e');
    }
  }
}
