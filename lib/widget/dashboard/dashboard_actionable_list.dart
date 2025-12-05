// lib/widgets/dashboard/common/dashboard_actionable_list.dart

import 'package:flutter/material.dart';
import 'package:tilework/models/dashboard/dashboard_models.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class DashboardActionableList extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final List<ActionableListItem> items;
  final String? emptyMessage;
  final VoidCallback? onViewAllTap;
  final bool showDividers;

  const DashboardActionableList({
    Key? key,
    required this.title,
    required this.titleIcon,
    required this.items,
    this.emptyMessage,
    this.onViewAllTap,
    this.showDividers = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ReportTheme.accentBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    titleIcon,
                    color: ReportTheme.accentDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: ReportTheme.headingSmall,
                      ),
                      Text(
                        '${items.length} items',
                        style: ReportTheme.caption,
                      ),
                    ],
                  ),
                ),
                if (onViewAllTap != null)
                  TextButton(
                    onPressed: onViewAllTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: ReportTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: ReportTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey.shade100),

          // List Items
          if (items.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (context, index) => showDividers
                  ? Divider(
                      height: 1,
                      indent: 70,
                      endIndent: 20,
                      color: Colors.grey.shade100,
                    )
                  : const SizedBox(height: 4),
              itemBuilder: (context, index) => _buildListItem(items[index], index),
            ),
        ],
      ),
    );
  }

  Widget _buildListItem(ActionableListItem item, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              // Rank/Index
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: index < 3
                      ? LinearGradient(
                          colors: _getRankColors(index),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: index >= 3 ? Colors.grey.shade200 : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: index < 3 ? Colors.white : ReportTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Icon (if provided)
              if (item.icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (item.badgeColor ?? ReportTheme.primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.badgeColor ?? ReportTheme.primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.badge != null)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: (item.badgeColor ?? ReportTheme.warningColor)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.badge!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: item.badgeColor ?? ReportTheme.warningColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: ReportTheme.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Value
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: item.badgeColor ?? ReportTheme.primaryColor,
                    ),
                  ),
                ],
              ),

              // Arrow
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade300,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getRankColors(int index) {
    switch (index) {
      case 0:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)]; // Gold
      case 1:
        return [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)]; // Silver
      case 2:
        return [const Color(0xFFCD7F32), const Color(0xFFA0522D)]; // Bronze
      default:
        return [Colors.grey.shade400, Colors.grey.shade300];
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              emptyMessage ?? 'No items to display',
              style: TextStyle(
                color: ReportTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}