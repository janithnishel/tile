import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/job_cost/job_cost_cubit.dart';
import 'package:tilework/theme/colors.dart';
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/cost_summary_row.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/invoice_items_tab.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/job_detail_header.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/other_expenses_tab.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/purchase_orders_tab.dart';
import 'package:tilework/services/pdf_service.dart';
import 'package:tilework/models/job_cost_report_models.dart';
import 'package:tilework/screens/job_cost_report_preview.dart';

class JobCostDetailScreen extends StatefulWidget {
  final JobCostDocument job;

  const JobCostDetailScreen({Key? key, required this.job}) : super(key: key);

  @override
  State<JobCostDetailScreen> createState() => _JobCostDetailScreenState();
}

class _JobCostDetailScreenState extends State<JobCostDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshUI() {
    setState(() {});
  }

  Future<void> _completeProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Project'),
        content: const Text(
          'Are you sure you want to mark this project as completed? '
          'It will be removed from the active job list.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Complete Project'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Update quotation status to closed
      // For now, just show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project marked as completed!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  Future<void> _exportToPDF() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating PDF report...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Convert JobCostDocument to JobCostReportData
      final reportData = JobCostReportData(
        jobId: widget.job.displayId,
        quotationNumber: widget.job.invoiceId,
        customerName: widget.job.customerName,
        customerAddress: 'Customer Address', // TODO: Add to JobCostDocument
        customerPhone: widget.job.customerPhone,
        projectDescription: widget.job.projectTitle,
        startDate: widget.job.invoiceDate,
        status: ProjectStatus.active, // TODO: Map from actual status
        items: widget.job.invoiceItems.map((item) => JobCostItem(
          itemCode: 'ITEM-${widget.job.invoiceItems.indexOf(item) + 1}',
          description: item.name,
          quantity: item.quantity,
          unit: 'units', // TODO: Add unit to InvoiceItem
          costPrice: item.costPrice,
          sellingPrice: item.sellingPrice,
        )).toList(),
        advanceReceived: 0, // TODO: Add advance payment tracking
        totalInvoiced: widget.job.totalRevenue,
      );

      // Navigate to PDF Preview Screen instead of just generating
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobCostReportPreview(
            reportData: reportData,
          ),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jobCostBackground,
      appBar: AppBar(
        title: Text('Job Cost Details - ${widget.job.displayId}'),
        backgroundColor: AppColors.jobCostPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _exportToPDF,
            icon: const Icon(Icons.download, color: Colors.white),
            tooltip: 'Export PDF Report',
          ),
          TextButton.icon(
            onPressed: _completeProject,
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            label: const Text(
              'Complete Project',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Header Card
            JobDetailHeader(job: widget.job),
            const SizedBox(height: 20),

            // Cost Summary Cards
            CostSummaryRow(job: widget.job),
            const SizedBox(height: 24),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.jobCostPrimary,
                    unselectedLabelColor: AppColors.grey600,
                    indicatorColor: AppColors.jobCostPrimary,
                    tabs: const [
                      Tab(icon: Icon(Icons.receipt), text: 'Quotation Items'),
                      Tab(
                        icon: Icon(Icons.shopping_cart),
                        text: 'Purchase Orders',
                      ),
                      Tab(icon: Icon(Icons.money_off), text: 'Other Expenses'),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        InvoiceItemsTab(job: widget.job, onDataChanged: _refreshUI),
                        PurchaseOrdersTab(job: widget.job),
                        OtherExpensesTab(job: widget.job, onDataChanged: _refreshUI),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
