import 'package:flutter/material.dart';
import '../theme/colors.dart';

class JobCostStatusHelpers {
  static Color getJobCostStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ordered':
        return Colors.orange;
      case 'delivered':
        return Colors.blue;
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  // Job Cost Profit/Loss Colors
  static Color getProfitColor(double value) {
    return value >= 0 ? AppColors.jobCostProfit : AppColors.jobCostLoss;
  }

  static Color getProfitBackgroundColor(double value) {
    return value >= 0 ? Colors.green.shade50 : Colors.red.shade50;
  }
}
