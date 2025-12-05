// lib/widgets/reports/common/report_dropdown_filter.dart

import 'package:flutter/material.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class ReportDropdownFilter<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final double? width;
  final String? hint;
  final bool isExpanded;
  final Widget? prefixIcon;
  final bool showClearButton;

  const ReportDropdownFilter({
    Key? key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.width,
    this.hint,
    this.isExpanded = true,
    this.prefixIcon,
    this.showClearButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 200,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value != null
                    ? ReportTheme.primaryColor.withOpacity(0.5)
                    : ReportTheme.dividerColor,
                width: value != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      value: value,
                      hint: Text(
                        hint ?? 'Select',
                        style: TextStyle(
                          color: ReportTheme.textHint,
                          fontSize: 13,
                        ),
                      ),
                      isExpanded: isExpanded,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: value != null
                            ? ReportTheme.primaryColor
                            : ReportTheme.textSecondary,
                      ),
                      items: items,
                      onChanged: onChanged,
                      style: TextStyle(
                        color: ReportTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 8,
                      menuMaxHeight: 300,
                    ),
                  ),
                ),
                if (showClearButton && value != null)
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: ReportTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Status Filter with colored indicators
class ReportStatusFilter extends StatelessWidget {
  final String label;
  final String? value;
  final List<StatusFilterOption> options;
  final Function(String?) onChanged;
  final double? width;

  const ReportStatusFilter({
    Key? key,
    required this.label,
    this.value,
    required this.options,
    required this.onChanged,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 200,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value != null && value != 'All'
                    ? ReportTheme.primaryColor.withOpacity(0.5)
                    : ReportTheme.dividerColor,
                width: value != null && value != 'All' ? 1.5 : 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: const Text('All Status'),
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: ReportTheme.textSecondary,
                ),
                items: options.map((option) {
                  return DropdownMenuItem<String>(
                    value: option.value,
                    child: Row(
                      children: [
                        if (option.color != null)
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: option.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (option.icon != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              option.icon,
                              size: 16,
                              color: option.color ?? ReportTheme.textSecondary,
                            ),
                          ),
                        Text(option.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                style: TextStyle(
                  color: ReportTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusFilterOption {
  final String value;
  final String label;
  final Color? color;
  final IconData? icon;

  const StatusFilterOption({
    required this.value,
    required this.label,
    this.color,
    this.icon,
  });
}

/// Chip-based filter selection
class ReportChipFilter extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final Function(String?) onSelected;

  const ReportChipFilter({
    Key? key,
    required this.label,
    required this.options,
    this.selectedValue,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                onSelected(selected ? option : null);
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: const Color(0xFFFFF8E1), // Amber 50
              checkmarkColor: ReportTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? ReportTheme.primaryColor
                    : ReportTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? ReportTheme.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            );
          }).toList(),
        ),
      ],
    );
  }
}