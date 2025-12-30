// Invoice Preview Screen
import 'package:flutter/material.dart';
import '../../models/site_visits/site_visit_model.dart';
import '../../widget/site_visits/invoice_widget.dart';
import '../../services/site_visits/print_service.dart';
import '../../utils/site_visits/constants.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final SiteVisitModel visit;

  const InvoicePreviewScreen({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareInvoice(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: InvoiceWidget(visit: visit),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _printInvoice(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.print, color: Colors.white),
                  label: const Text(
                    'Print Invoice',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _savePDF(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.infoBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text(
                    'Save as PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _printInvoice(BuildContext context) async {
    await PrintService.printInvoice(visit);
  }

  void _savePDF(BuildContext context) async {
    final path = await PrintService.savePDF(visit);
    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved: $path'),
          backgroundColor: AppColors.successGreen,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () {
              // Open PDF
            },
          ),
        ),
      );
    }
  }

  void _shareInvoice(BuildContext context) async {
    await PrintService.shareInvoice(visit);
  }
}