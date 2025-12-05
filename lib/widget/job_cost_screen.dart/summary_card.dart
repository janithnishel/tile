import 'package:flutter/material.dart';
import '../shared/stat_card.dart' as shared;

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final double? iconSize;
  final double? valueSize;

  const SummaryCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.iconSize = 28,
    this.valueSize = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return shared.StatCard(
      icon: icon,
      title: title,
      value: value,
      color: color,
      iconSize: iconSize,
      valueSize: valueSize,
      isVertical: true,
      borderRadius: 16,
      padding: const EdgeInsets.all(20),
    );
  }
}
