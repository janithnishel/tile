import 'package:flutter/material.dart';
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';
import 'package:tilework/theme/colors.dart';
import 'package:tilework/utils/job_cost_status_helper.dart';

class JobCostHeader extends StatelessWidget {
  final JobCostDocument? selectedJob;
  final List<JobCostDocument> jobs;
  final Function(JobCostDocument?) onJobSelected;
  final Function(String) onSearchChanged;
  final VoidCallback? onBackPressed;

  const JobCostHeader({
    Key? key,
    required this.selectedJob,
    required this.jobs,
    required this.onJobSelected,
    required this.onSearchChanged,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(context),
          if (selectedJob == null) ...[
            const SizedBox(height: 20),
            _buildFilterRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.jobCostPrimaryLight, AppColors.jobCostPrimaryDark],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.analytics, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Job Cost Analysis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Track company expenses and profit margins',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.jobCostTextSecondary,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (selectedJob != null)
          OutlinedButton.icon(
            onPressed: onBackPressed,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to List'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildJobDropdown(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSearchField(),
        ),
      ],
    );
  }

  Widget _buildJobDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<JobCostDocument>(
          value: null,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(Icons.search, color: AppColors.jobCostTextHint),
              const SizedBox(width: 12),
              Text(
                'Select Invoice (ID, Customer, Phone)...',
                style: TextStyle(color: AppColors.jobCostTextSecondary),
              ),
            ],
          ),
          items: jobs.map((job) => _buildDropdownItem(job)).toList(),
          onChanged: (job) => onJobSelected(job),
        ),
      ),
    );
  }

  DropdownMenuItem<JobCostDocument> _buildDropdownItem(JobCostDocument job) {
    return DropdownMenuItem<JobCostDocument>(
      value: job,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Invoice ID Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.teal100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                job.displayId,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.teal600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Customer Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    job.customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 12, color: AppColors.jobCostTextHint),
                      const SizedBox(width: 4),
                      Text(
                        job.customerPhone,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.jobCostTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.work, size: 12, color: AppColors.jobCostTextHint),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          job.projectTitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.jobCostTextSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Profit indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JobCostStatusHelpers.getProfitBackgroundColor(job.profitMargin),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${job.profitMargin.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: JobCostStatusHelpers.getProfitColor(job.profitMargin),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Quick search...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
