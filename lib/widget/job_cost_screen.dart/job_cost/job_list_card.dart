import 'package:flutter/material.dart';
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';
import 'package:tilework/utils/job_cost_formatters.dart';
import 'package:tilework/utils/job_cost_status_helper.dart';

class JobListCard extends StatelessWidget {
  final JobCostDocument job;
  final VoidCallback onTap;

  const JobListCard({
    Key? key,
    required this.job,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildInvoiceIdBadge(),
                const SizedBox(width: 16),
                _buildCustomerInfo(),
                _buildRevenueColumn(),
                _buildCostColumn(),
                _buildProfitColumn(),
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceIdBadge() {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long, color: Colors.teal.shade600),
          const SizedBox(height: 4),
          Text(
            job.displayId,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.customerName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                job.customerPhone,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.work, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  job.projectTitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueColumn() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Revenue',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
          Text(
            AppFormatters.formatCurrency(job.totalRevenue),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostColumn() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Cost',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
          Text(
            AppFormatters.formatCurrency(job.totalCost),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitColumn() {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: JobCostStatusHelpers.getProfitBackgroundColor(job.profit),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            AppFormatters.formatCurrency(job.profit),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: JobCostStatusHelpers.getProfitColor(job.profit),
            ),
          ),
          Text(
            '${job.profitMargin.toStringAsFixed(1)}% margin',
            style: TextStyle(
              fontSize: 10,
              color: JobCostStatusHelpers.getProfitColor(job.profit),
            ),
          ),
        ],
      ),
    );
  }
}
