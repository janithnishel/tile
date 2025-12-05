// lib/widgets/reports/common/report_date_range_picker.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class ReportDateRangePicker extends StatelessWidget {
  final DateTimeRange? dateRange;
  final Function(DateTimeRange?) onDateRangeChanged;
  final String label;
  final double? width;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const ReportDateRangePicker({
    Key? key,
    this.dateRange,
    required this.onDateRangeChanged,
    this.label = 'Date Range',
    this.width,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 340,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: ReportTheme.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: ReportTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showDateRangePicker(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: dateRange != null
                      ? ReportTheme.primaryColor.withOpacity(0.05)
                      : ReportTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: dateRange != null
                        ? ReportTheme.primaryColor.withOpacity(0.3)
                        : ReportTheme.dividerColor.withOpacity(0.5),
                    width: dateRange != null ? 2 : 1.5,
                  ),
                  boxShadow: dateRange != null
                      ? [
                          BoxShadow(
                            color: ReportTheme.primaryColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ReportTheme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ReportTheme.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: ReportTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dateRange != null
                            ? '${_formatDate(dateRange!.start)} - ${_formatDate(dateRange!.end)}'
                            : 'Select date range',
                        style: TextStyle(
                          color: dateRange != null
                              ? ReportTheme.textPrimary
                              : ReportTheme.textHint,
                          fontSize: 13,
                          fontWeight: dateRange != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (dateRange != null)
                      GestureDetector(
                        onTap: () => onDateRangeChanged(null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: ReportTheme.accentBackground,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ReportTheme.accentColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: ReportTheme.accentDark,
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.arrow_drop_down,
                        color: ReportTheme.textSecondary,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
      initialDateRange: dateRange,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              // Primary - Purple (selected dates, headers)
              primary: ReportTheme.primaryColor,
              onPrimary: Colors.white,

              // Secondary - Yellow/Amber (accents)
              secondary: const Color(0xFFFFC107), // Amber
              onSecondary: Colors.black,

              // Tertiary - Yellow for highlights
              tertiary: const Color(0xFFFFD54F), // Amber 300
              onTertiary: Colors.black,

              // Surface colors
              surface: Colors.white,
              onSurface: ReportTheme.textPrimary,

              // Background
              background: Colors.white,
              onBackground: ReportTheme.textPrimary,

              // Primary container (date range selection background)
              primaryContainer: ReportTheme.primaryColor.withOpacity(0.15),
              onPrimaryContainer: ReportTheme.primaryColor,

              // Secondary container
              secondaryContainer: const Color(0xFFFFF8E1), // Amber 50
              onSecondaryContainer: const Color(0xFFF57F17), // Yellow 900
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ReportTheme.primaryColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 16,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: ReportTheme.primaryColor,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              weekdayStyle: TextStyle(
                color: ReportTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              dayStyle: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              // Selected day style
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return ReportTheme.primaryColor;
                }
                return null;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                if (states.contains(WidgetState.disabled)) {
                  return Colors.grey.shade400;
                }
                return ReportTheme.textPrimary;
              }),
              // Today style
              todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return ReportTheme.primaryColor;
                }
                return Colors.transparent;
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return const Color(0xFFFFC107); // Amber - Today highlight
              }),
              todayBorder: BorderSide(
                color: const Color(0xFFFFC107), // Amber border for today
                width: 2,
              ),
              // Range selection colors
              rangePickerBackgroundColor: Colors.white,
              rangePickerHeaderBackgroundColor: ReportTheme.primaryColor,
              rangePickerHeaderForegroundColor: Colors.white,
              rangePickerHeaderHeadlineStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              rangeSelectionBackgroundColor: const Color(0xFFFFF8E1), // Amber 50 - Range background
              rangePickerSurfaceTintColor: Colors.transparent,
              // Shape
              dayShape: WidgetStateProperty.all(const CircleBorder()),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              rangePickerShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              rangePickerElevation: 0,
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
          ),
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 350,
                  maxHeight: 450,
                ),
                child: child!,
              ),
            ),
          ),
        );
      },
    );
    
    if (picked != null) {
      onDateRangeChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}

/// Quick Date Range Presets Widget
class DateRangePresets extends StatelessWidget {
  final Function(DateTimeRange) onPresetSelected;
  
  const DateRangePresets({
    Key? key,
    required this.onPresetSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _PresetChip(
          label: 'Today',
          onTap: () => onPresetSelected(_getToday()),
        ),
        _PresetChip(
          label: 'This Week',
          onTap: () => onPresetSelected(_getThisWeek()),
        ),
        _PresetChip(
          label: 'This Month',
          onTap: () => onPresetSelected(_getThisMonth()),
        ),
        _PresetChip(
          label: 'Last 30 Days',
          onTap: () => onPresetSelected(_getLast30Days()),
        ),
        _PresetChip(
          label: 'Last 3 Months',
          onTap: () => onPresetSelected(_getLast3Months()),
        ),
        _PresetChip(
          label: 'This Year',
          onTap: () => onPresetSelected(_getThisYear()),
        ),
      ],
    );
  }

  DateTimeRange _getToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTimeRange(start: today, end: today);
  }

  DateTimeRange _getThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return DateTimeRange(
      start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  DateTimeRange _getThisMonth() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  DateTimeRange _getLast30Days() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30)),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  DateTimeRange _getLast3Months() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month - 3, now.day),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  DateTimeRange _getThisYear() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, 1, 1),
      end: DateTime(now.year, now.month, now.day),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1), // Amber 50
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFE082), // Amber 200
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ReportTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
