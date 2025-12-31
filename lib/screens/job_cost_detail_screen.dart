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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jobCostBackground,
      appBar: AppBar(
        title: Text('Job Cost Details - ${widget.job.displayId}'),
        backgroundColor: AppColors.jobCostPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
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
                      Tab(icon: Icon(Icons.receipt), text: 'Invoice Items'),
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
