import 'package:flutter/material.dart';
import 'package:tilework/data/job_cost_mock_data.dart';
import 'package:tilework/theme/colors.dart';
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/cost_summary_row.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/invoice_items_tab.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/job_cost_header.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/job_detail_header.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/job_list_card.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/other_expenses_tab.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/overall_summary_cards.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/purchase_orders_tab.dart';

class JobCostScreen extends StatefulWidget {
  const JobCostScreen({Key? key}) : super(key: key);

  @override
  State<JobCostScreen> createState() => _JobCostScreenState();
}

class _JobCostScreenState extends State<JobCostScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  JobCostDocument? _selectedJob;
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

  List<JobCostDocument> get _filteredJobs {
    if (_searchQuery.isEmpty) return MockData.jobCosts;

    final query = _searchQuery.toLowerCase();
    return MockData.jobCosts.where((job) {
      return job.invoiceId.toLowerCase().contains(query) ||
          job.customerName.toLowerCase().contains(query) ||
          job.customerPhone.toLowerCase().contains(query) ||
          job.projectTitle.toLowerCase().contains(query);
    }).toList();
  }

  void _refreshUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.jobCostBackground,
      child: Column(
        children: [
          // Header
          JobCostHeader(
            selectedJob: _selectedJob,
            jobs: MockData.jobCosts,
            onJobSelected: (JobCostDocument? job) {
              setState(() {
                _selectedJob = job;
              });
            },
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onBackPressed: () {
              setState(() {
                _selectedJob = null;
              });
            },
          ),

          // Main Content
          Expanded(
            child: _selectedJob == null
                ? _buildJobSelectionView()
                : _buildJobCostDetailView(),
          ),
        ],
      ),
    );
  }

  Widget _buildJobSelectionView() {
    final jobs = _filteredJobs;

    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No jobs found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          const OverallSummaryCards(),
          const SizedBox(height: 24),

          // Job List
          const Text(
            'All Jobs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...jobs.map(
            (job) => JobListCard(
              job: job,
              onTap: () {
                setState(() {
                  _selectedJob = job;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCostDetailView() {
    final job = _selectedJob!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Header Card
          JobDetailHeader(job: job),
          const SizedBox(height: 20),

          // Cost Summary Cards
          CostSummaryRow(job: job),
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
                      InvoiceItemsTab(job: job, onDataChanged: _refreshUI),
                      PurchaseOrdersTab(job: job),
                      OtherExpensesTab(job: job, onDataChanged: _refreshUI),
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
}
