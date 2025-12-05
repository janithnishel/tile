// lib/widgets/reports/common/report_data_table.dart

import 'package:flutter/material.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class ReportDataTable<T> extends StatefulWidget {
  final List<T> data;
  final List<ReportDataColumn<T>> columns;
  final int rowsPerPage;
  final String? emptyMessage;
  final bool showCheckbox;
  final Function(T)? onRowTap;
  final Function(List<T>)? onSelectionChanged;
  final Widget? header;
  final List<Widget>? actions;

  const ReportDataTable({
    Key? key,
    required this.data,
    required this.columns,
    this.rowsPerPage = 10,
    this.emptyMessage,
    this.showCheckbox = false,
    this.onRowTap,
    this.onSelectionChanged,
    this.header,
    this.actions,
  }) : super(key: key);

  @override
  State<ReportDataTable<T>> createState() => _ReportDataTableState<T>();
}

class _ReportDataTableState<T> extends State<ReportDataTable<T>> {
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final Set<int> _selectedRows = {};
  late List<T> _sortedData;

  @override
  void initState() {
    super.initState();
    _sortedData = List.from(widget.data);
  }

  @override
  void didUpdateWidget(ReportDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _sortedData = List.from(widget.data);
      _selectedRows.clear();
      if (_sortColumnIndex != null) {
        _sortData(_sortColumnIndex!, _sortAscending);
      }
    }
  }

  void _sortData(int columnIndex, bool ascending) {
    final column = widget.columns[columnIndex];
    if (column.sortable && column.compareFunction != null) {
      _sortedData.sort((a, b) {
        final result = column.compareFunction!(a, b);
        return ascending ? result : -result;
      });
    }
  }

  int get _totalPages => (widget.data.length / widget.rowsPerPage).ceil();
  
  List<T> get _currentPageData {
    final start = _currentPage * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, _sortedData.length);
    return _sortedData.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ReportTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null || widget.actions != null)
            _buildHeader(),
          _buildTable(),
          if (_totalPages > 1) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ReportTheme.primaryColor.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          if (widget.header != null) Expanded(child: widget.header!),
          if (widget.actions != null) ...widget.actions!,
        ],
      ),
    );
  }

  Widget _buildTable() {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 32,
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            ReportTheme.primaryColor.withOpacity(0.08),
          ),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return ReportTheme.primaryColor.withOpacity(0.04);
            }
            return null;
          }),
          headingRowHeight: 56,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 60,
          horizontalMargin: 20,
          columnSpacing: 24,
          showCheckboxColumn: widget.showCheckbox,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: widget.columns.asMap().entries.map((entry) {
            final index = entry.key;
            final column = entry.value;
            return DataColumn(
              label: Text(
                column.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ReportTheme.textPrimary,
                ),
              ),
              numeric: column.numeric,
              onSort: column.sortable
                  ? (columnIndex, ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                        _sortData(columnIndex, ascending);
                      });
                    }
                  : null,
            );
          }).toList(),
          rows: _currentPageData.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final actualIndex = _currentPage * widget.rowsPerPage + index;
            return DataRow(
              selected: _selectedRows.contains(actualIndex),
              onSelectChanged: widget.showCheckbox
                  ? (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedRows.add(actualIndex);
                        } else {
                          _selectedRows.remove(actualIndex);
                        }
                      });
                      widget.onSelectionChanged?.call(
                        _selectedRows
                            .map((i) => _sortedData[i])
                            .toList(),
                      );
                    }
                  : null,
              onLongPress: widget.onRowTap != null
                  ? () => widget.onRowTap!(item)
                  : null,
              cells: widget.columns.map((column) {
                return DataCell(
                  column.cellBuilder(item),
                  onTap: widget.onRowTap != null
                      ? () => widget.onRowTap!(item)
                      : null,
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyMessage ?? 'No data available',
            style: TextStyle(
              fontSize: 16,
              color: ReportTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: ReportTheme.dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${_currentPage * widget.rowsPerPage + 1} - ${((_currentPage + 1) * widget.rowsPerPage).clamp(0, widget.data.length)} of ${widget.data.length}',
            style: ReportTheme.caption,
          ),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage = 0)
                    : null,
                icon: const Icon(Icons.first_page),
                iconSize: 20,
                color: ReportTheme.primaryColor,
                disabledColor: Colors.grey.shade300,
              ),
              IconButton(
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
                iconSize: 20,
                color: ReportTheme.primaryColor,
                disabledColor: Colors.grey.shade300,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: ReportTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                onPressed: _currentPage < _totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
                iconSize: 20,
                color: ReportTheme.primaryColor,
                disabledColor: Colors.grey.shade300,
              ),
              IconButton(
                onPressed: _currentPage < _totalPages - 1
                    ? () => setState(() => _currentPage = _totalPages - 1)
                    : null,
                icon: const Icon(Icons.last_page),
                iconSize: 20,
                color: ReportTheme.primaryColor,
                disabledColor: Colors.grey.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Column Definition
class ReportDataColumn<T> {
  final String label;
  final Widget Function(T item) cellBuilder;
  final bool sortable;
  final bool numeric;
  final int Function(T a, T b)? compareFunction;

  const ReportDataColumn({
    required this.label,
    required this.cellBuilder,
    this.sortable = false,
    this.numeric = false,
    this.compareFunction,
  });
}

// Action Button for Table Cells
class ReportTableActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  const ReportTableActionButton({
    Key? key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? ReportTheme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color ?? ReportTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

// Status Badge Widget
class ReportStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const ReportStatusBadge({
    Key? key,
    required this.label,
    required this.color,
    this.icon,
  }) : super(key: key);

  // Factory constructors for common statuses
  factory ReportStatusBadge.paid() => const ReportStatusBadge(
    label: 'Paid',
    color: ReportTheme.successColor,
    icon: Icons.check_circle_outline,
  );

  factory ReportStatusBadge.pending() => const ReportStatusBadge(
    label: 'Pending',
    color: ReportTheme.warningColor,
    icon: Icons.access_time,
  );

  factory ReportStatusBadge.partial() => const ReportStatusBadge(
    label: 'Partial',
    color: ReportTheme.infoColor,
    icon: Icons.pie_chart_outline,
  );

  factory ReportStatusBadge.overdue() => const ReportStatusBadge(
    label: 'Overdue',
    color: ReportTheme.errorColor,
    icon: Icons.warning_amber,
  );

  factory ReportStatusBadge.active() => const ReportStatusBadge(
    label: 'Active',
    color: ReportTheme.successColor,
    icon: Icons.play_circle_outline,
  );

  factory ReportStatusBadge.completed() => const ReportStatusBadge(
    label: 'Completed',
    color: ReportTheme.infoColor,
    icon: Icons.check_circle,
  );

  factory ReportStatusBadge.onHold() => const ReportStatusBadge(
    label: 'On Hold',
    color: ReportTheme.warningColor,
    icon: Icons.pause_circle_outline,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}