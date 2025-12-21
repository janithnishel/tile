import 'package:flutter/material.dart';

class POStatusHelpers {
  // Get color for PO status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.yellow.shade700; // Yellow for Draft
      case 'ordered':
        return Colors.blue.shade600; // Blue for Ordered
      case 'delivered':
        return Colors.teal.shade600; // Keep teal for Delivered
      case 'paid':
        return Colors.green.shade600; // Green for Paid
      case 'cancelled':
        return Colors.red.shade600; // Red for Cancelled
      default:
        return Colors.grey.shade600;
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
    'Active',
    'Draft',
    'Ordered',
    'Delivered',
    'Paid',
    'Cancelled',
  ];
}
