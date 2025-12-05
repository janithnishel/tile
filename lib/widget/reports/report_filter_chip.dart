// lib/widgets/reports/common/report_filter_bar.dart

import 'package:flutter/material.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class ReportFilterBar extends StatelessWidget {
  final List<Widget> filters;
  final VoidCallback? onClearFilters;
  final bool showClearButton;
  final EdgeInsetsGeometry? padding;

  const ReportFilterBar({
    Key? key,
    required this.filters,
    this.onClearFilters,
    this.showClearButton = true,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: ReportTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: ReportTheme.headingSmall.copyWith(
                  color: ReportTheme.primaryColor,
                ),
              ),
              const Spacer(),
              if (showClearButton && onClearFilters != null)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: ReportTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: filters.map((filter) => Expanded(child: filter)).toList(),
          ),
        ],
      ),
    );
  }
}
