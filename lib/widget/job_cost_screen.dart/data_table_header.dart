import 'package:flutter/material.dart';

class DataTableHeader extends StatelessWidget {
  final List<DataTableColumn> columns;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const DataTableHeader({
    Key? key,
    required this.columns,
    this.backgroundColor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: columns.map((col) {
          return Expanded(
            flex: col.flex,
            child: Text(
              col.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: col.alignment,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DataTableColumn {
  final String label;
  final int flex;
  final TextAlign alignment;

  const DataTableColumn({
    required this.label,
    this.flex = 1,
    this.alignment = TextAlign.left,
  });
}