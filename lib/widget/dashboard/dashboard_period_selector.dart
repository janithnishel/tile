// lib/widgets/dashboard/common/dashboard_period_selector.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/dashboard/dashboard_models.dart';
import 'package:tilework/widget/reports/report_theme.dart';
class DashboardPeriodSelector extends StatelessWidget {
  final DashboardPeriod selectedPeriod;
  final DateTimeRange? customDateRange;
  final Function(DashboardPeriod) onPeriodChanged;
  final Function(DateTimeRange)? onCustomDateRangeSelected;

  const DashboardPeriodSelector({
    Key? key,
    required this.selectedPeriod,
    this.customDateRange,
    required this.onPeriodChanged,
    this.onCustomDateRangeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ReportTheme.accentBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.date_range_rounded,
                  color: ReportTheme.accentDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Select Period',
                style: ReportTheme.headingSmall.copyWith(
                  color: ReportTheme.textPrimary,
                ),
              ),
              const Spacer(),
              if (selectedPeriod != DashboardPeriod.custom)
                _buildDateRangeDisplay(),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DashboardPeriod.values.map((period) {
                if (period == DashboardPeriod.custom) {
                  return _buildCustomPeriodChip(context, period);
                }
                return _buildPeriodChip(period);
              }).toList(),
            ),
          ),
          if (selectedPeriod == DashboardPeriod.custom && customDateRange != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildCustomDateDisplay(),
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(DashboardPeriod period) {
    final isSelected = selectedPeriod == period;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onPeriodChanged(period),
          borderRadius: BorderRadius.circular(25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        ReportTheme.primaryColor,
                        ReportTheme.primaryLight,
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Colors.grey.shade300,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ReportTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              period.label,
              style: TextStyle(
                color: isSelected ? Colors.white : ReportTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomPeriodChip(BuildContext context, DashboardPeriod period) {
    final isSelected = selectedPeriod == period;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCustomDatePicker(context),
          borderRadius: BorderRadius.circular(25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        ReportTheme.accentDark,
                        ReportTheme.accentColor,
                      ],
                    )
                  : null,
              color: isSelected ? null : ReportTheme.accentBackground,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : ReportTheme.accentColor.withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: isSelected ? Colors.white : ReportTheme.accentDark,
                ),
                const SizedBox(width: 6),
                Text(
                  period.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : ReportTheme.accentDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeDisplay() {
    final range = selectedPeriod.dateRange;
    final format = DateFormat('dd MMM');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ReportTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 14,
            color: ReportTheme.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            '${format.format(range.start)} - ${format.format(range.end)}',
            style: TextStyle(
              fontSize: 12,
              color: ReportTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDateDisplay() {
    final format = DateFormat('dd MMM yyyy');
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ReportTheme.accentBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ReportTheme.accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.date_range,
            color: ReportTheme.accentDark,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            '${format.format(customDateRange!.start)} - ${format.format(customDateRange!.end)}',
            style: TextStyle(
              color: ReportTheme.accentDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '${customDateRange!.duration.inDays + 1} days',
            style: TextStyle(
              color: ReportTheme.accentDark.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomDatePicker(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: customDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ReportTheme.primaryColor,
              onPrimary: Colors.white,
              secondary: ReportTheme.accentColor,
              onSecondary: Colors.black,
              surface: Colors.white,
              onSurface: ReportTheme.textPrimary,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: ReportTheme.primaryColor.withOpacity(0.1),
              headerBackgroundColor: ReportTheme.primaryColor,
              headerForegroundColor: Colors.white,
              rangeSelectionBackgroundColor: ReportTheme.accentBackground,
              todayBorder: BorderSide(color: ReportTheme.accentColor, width: 2),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return ReportTheme.accentColor;
              }),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
                child: child!,
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      onPeriodChanged(DashboardPeriod.custom);
      onCustomDateRangeSelected?.call(picked);
    }
  }
}
