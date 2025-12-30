// Customer Expansion Tile Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/site_visits/site_visit_model.dart';
import '../../utils/site_visits/constants.dart';
import 'status_badge.dart';

class CustomerExpansionTile extends StatelessWidget {
  final String customerName;
  final List<SiteVisitModel> visits;
  final Function(SiteVisitModel) onVisitTap;

  const CustomerExpansionTile({
    super.key,
    required this.customerName,
    required this.visits,
    required this.onVisitTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalCharge = visits.fold(0.0, (sum, v) => sum + v.charge);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 16),
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryPurple,
            radius: 24,
            child: Text(
              customerName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          title: Text(
            customerName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      visits.first.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurpleLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${visits.length} Visits',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successGreenLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Rs ${NumberFormat('#,###').format(totalCharge)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const Divider(height: 1),
            ...visits.map((visit) => _buildVisitItem(context, visit, dateFormat)),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitItem(
      BuildContext context, SiteVisitModel visit, DateFormat dateFormat) {
    return InkWell(
      onTap: () => onVisitTap(visit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor(visit.status),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        visit.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        status: visit.status,
                        fontSize: 10,
                        showIcon: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visit.projectTitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(visit.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Rs ${NumberFormat('#,###').format(visit.charge)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SiteVisitStatus status) {
    switch (status) {
      case SiteVisitStatus.converted:
        return AppColors.successGreen;
      case SiteVisitStatus.pending:
        return AppColors.warningYellow;
      case SiteVisitStatus.invoiced:
        return AppColors.infoBlue;
    }
  }
}