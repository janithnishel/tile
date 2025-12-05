import 'package:flutter/material.dart';
import '../shared/stat_card.dart' as shared;

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isWide;

  const StatCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.isWide = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return shared.StatCard(
      icon: icon,
      title: title,
      value: value,
      color: color,
      isWide: isWide,
      borderRadius: 12,
    );
  }
}
