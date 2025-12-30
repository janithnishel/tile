// Status Badge Widget
import 'package:flutter/material.dart';
import '../../models/site_visits/site_visit_model.dart';
import '../../utils/site_visits/constants.dart';

class StatusBadge extends StatelessWidget {
  final SiteVisitStatus status;
  final bool showIcon;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getBorderColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getIcon(),
              size: 14,
              color: _getTextColor(),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              color: _getTextColor(),
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case SiteVisitStatus.converted:
        return AppColors.successGreenLight;
      case SiteVisitStatus.pending:
        return AppColors.warningYellowLight;
      case SiteVisitStatus.invoiced:
        return AppColors.infoBlueLight;
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case SiteVisitStatus.converted:
        return AppColors.successGreen.withOpacity(0.5);
      case SiteVisitStatus.pending:
        return AppColors.warningYellow.withOpacity(0.5);
      case SiteVisitStatus.invoiced:
        return AppColors.infoBlue.withOpacity(0.5);
    }
  }

  Color _getTextColor() {
    switch (status) {
      case SiteVisitStatus.converted:
        return AppColors.successGreen;
      case SiteVisitStatus.pending:
        return Colors.amber.shade800;
      case SiteVisitStatus.invoiced:
        return AppColors.infoBlue;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case SiteVisitStatus.converted:
        return Icons.check_circle;
      case SiteVisitStatus.pending:
        return Icons.schedule;
      case SiteVisitStatus.invoiced:
        return Icons.description;
    }
  }
}