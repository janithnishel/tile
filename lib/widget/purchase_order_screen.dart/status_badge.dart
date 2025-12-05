import 'package:flutter/material.dart';
import '../shared/status_badge.dart' as shared;
import '../../utils/po_status_helpers.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    Key? key,
    required this.status,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return shared.StatusBadge(
      status: status,
      fontSize: fontSize,
      padding: padding,
      colorGetter: POStatusHelpers.getStatusColor,
      hasBorder: true,
    );
  }
}
