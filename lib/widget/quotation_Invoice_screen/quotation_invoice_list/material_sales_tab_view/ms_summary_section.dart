// lib/widget/material_sale/sections/ms_summary_section.dart

import 'package:flutter/material.dart';

class MSSummarySection extends StatelessWidget {
  final double totalAmount;
  final double totalCost;
  final double totalProfit;
  final double profitPercentage;
  final double totalSqft;
  final double totalPlanks;
  final int itemCount;

  const MSSummarySection({
    Key? key,
    required this.totalAmount,
    required this.totalCost,
    required this.totalProfit,
    required this.profitPercentage,
    required this.totalSqft,
    required this.totalPlanks,
    required this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade50,
            Colors.orange.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 16),

          // Quick Stats Row
          _buildQuickStats(),
          const SizedBox(height: 16),

          // Financial Summary
          _buildFinancialSummary(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.summarize_outlined,
            color: Colors.orange.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Sale Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _QuickStatItem(
          icon: Icons.inventory_2,
          label: 'Items',
          value: itemCount.toString(),
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
        _QuickStatItem(
          icon: Icons.view_module,
          label: 'Planks',
          value: totalPlanks.toStringAsFixed(0),
          color: Colors.purple,
        ),
        const SizedBox(width: 16),
        _QuickStatItem(
          icon: Icons.square_foot,
          label: 'Sqft',
          value: totalSqft.toStringAsFixed(1),
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Amount Row
          _FinancialRow(
            label: 'Total Sale Amount',
            value: totalAmount,
            color: Colors.blue.shade700,
            isTotal: true,
          ),
          const Divider(height: 24),
          
          // Cost Row
          _FinancialRow(
            label: 'Total Cost',
            value: totalCost,
            color: Colors.orange.shade700,
            prefix: '(-) ',
          ),
          const SizedBox(height: 8),
          
          // Profit Row
          _FinancialRow(
            label: 'Profit',
            value: totalProfit,
            color: totalProfit >= 0 ? Colors.green.shade700 : Colors.red.shade700,
            suffix: ' (${profitPercentage.toStringAsFixed(1)}%)',
            isProfit: true,
          ),
        ],
      ),
    );
  }
}

// ============================================
// QUICK STAT ITEM
// ============================================

class _QuickStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// FINANCIAL ROW
// ============================================

class _FinancialRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String? prefix;
  final String? suffix;
  final bool isTotal;
  final bool isProfit;

  const _FinancialRow({
    required this.label,
    required this.value,
    required this.color,
    this.prefix,
    this.suffix,
    this.isTotal = false,
    this.isProfit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: Colors.grey.shade700,
          ),
        ),
        Row(
          children: [
            if (isProfit && value >= 0)
              Icon(Icons.trending_up, color: color, size: 16),
            if (isProfit && value < 0)
              Icon(Icons.trending_down, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              '${prefix ?? ''}Rs. ${value.toStringAsFixed(0)}${suffix ?? ''}',
              style: TextStyle(
                fontSize: isTotal ? 18 : 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}