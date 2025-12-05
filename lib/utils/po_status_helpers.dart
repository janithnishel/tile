import 'package:flutter/material.dart';

class POStatusHelpers {
  // Get color for PO status
  static Color getStatusColor(String status) {
    switch (status) {
      case 'Draft':
        return Colors.grey;
      case 'Ordered':
        return Colors.orange;
      case 'Delivered':
        return Colors.blue;
      case 'Paid':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Get icon for status
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'Draft':
        return Icons.edit;
      case 'Ordered':
        return Icons.local_shipping;
      case 'Delivered':
        return Icons.check_circle;
      case 'Paid':
        return Icons.payment;
      default:
        return Icons.help;
    }
  }

  // Get next action icon
  static IconData getNextActionIcon(String currentStatus) {
    switch (currentStatus) {
      case 'Draft':
        return Icons.send;
      case 'Ordered':
        return Icons.check_circle;
      case 'Delivered':
        return Icons.payment;
      default:
        return Icons.check;
    }
  }

  // Get all status options
  static List<String> get allStatuses => [
    'All',
    'Draft',
    'Ordered',
    'Delivered',
    'Paid',
  ];
}