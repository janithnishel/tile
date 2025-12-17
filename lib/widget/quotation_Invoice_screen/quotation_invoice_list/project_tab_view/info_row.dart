import 'package:flutter/material.dart';

class InfoRowWidget extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const InfoRowWidget({
    Key? key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: labelStyle ??
                const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
          ),
          Text(
            value,
            style: valueStyle ?? const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}