import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/job_cost_report_models.dart';
import '../services/pdf_service.dart';

class JobCostReportPreview extends StatelessWidget {
  final JobCostReportData reportData;

  const JobCostReportPreview({
    super.key,
    required this.reportData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report - ${reportData.jobId}'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          // Save Button
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save PDF',
            onPressed: () => _savePdf(context),
          ),
          // Print Button
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print PDF',
            onPressed: () => _printPdf(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => JobCostPdfService.generateReport(reportData),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: 'JobCost_${reportData.jobId}.pdf',
        loadingWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF1565C0)),
              SizedBox(height: 16),
              Text('Generating PDF...'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePdf(BuildContext context) async {
    try {
      final pdfBytes = await JobCostPdfService.generateReport(reportData);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'JobCost_${reportData.jobId}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _printPdf(BuildContext context) async {
    try {
      final pdfBytes = await JobCostPdfService.generateReport(reportData);
      await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
