// lib/widgets/dashboard/common/dashboard_section_header.dart

import 'package:flutter/material.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onActionTap;
  final Widget? trailing;

  const DashboardSectionHeader({
    Key? key,
    required this.title,
    this.icon,
    this.actionText,
    this.onActionTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ReportTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: ReportTheme.primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            title,
            style: ReportTheme.headingSmall.copyWith(
              color: ReportTheme.textPrimary,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
          if (actionText != null && onActionTap != null)
            TextButton(
              onPressed: onActionTap,
              style: TextButton.styleFrom(
                foregroundColor: ReportTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios, size: 12),
                ],
              ),
            ),
        ],
      ),
    );
  }
}