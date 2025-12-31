import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/job_cost/job_cost_cubit.dart';
import 'package:tilework/cubits/job_cost/job_cost_state.dart';
import 'package:tilework/theme/colors.dart';
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/job_cost_header.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/job_list_card.dart';
import 'package:tilework/widget/job_cost_screen.dart/job_cost/overall_summary_cards.dart';
import 'package:tilework/screens/job_cost_detail_screen.dart';

class JobCostScreen extends StatefulWidget {
  const JobCostScreen({Key? key}) : super(key: key);

  @override
  State<JobCostScreen> createState() => _JobCostScreenState();
}

class _JobCostScreenState extends State<JobCostScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load job costs when screen initializes
    context.read<JobCostCubit>().loadJobCosts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobCostCubit, JobCostState>(
      builder: (context, state) {
        return Container(
          color: AppColors.jobCostBackground,
          child: Column(
            children: [
              // Header
              JobCostHeader(
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),

              // Main Content
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildJobSelectionView(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJobSelectionView(JobCostState state) {
    final jobs = _filteredJobs(state.jobCosts);

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
          OverallSummaryCards(jobCosts: state.jobCosts),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobCostDetailScreen(job: job),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<JobCostDocument> _filteredJobs(List<JobCostDocument> jobs) {
    if (_searchQuery.isEmpty) return jobs;

    final query = _searchQuery.toLowerCase();
    return jobs.where((job) {
      return job.invoiceId.toLowerCase().contains(query) ||
          job.customerName.toLowerCase().contains(query) ||
          job.customerPhone.toLowerCase().contains(query) ||
          job.projectTitle.toLowerCase().contains(query);
    }).toList();
  }
}
