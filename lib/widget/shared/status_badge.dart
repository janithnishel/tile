import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final Color Function(String) colorGetter;
  final bool hasBorder;

  const StatusBadge({
    Key? key,
    required this.status,
    this.fontSize = 10,
    this.padding,
    required this.colorGetter,
    this.hasBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = colorGetter(status);

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: hasBorder ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
