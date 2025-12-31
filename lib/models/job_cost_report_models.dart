import 'package:flutter/material.dart';

enum ProjectStatus {
  active,
  invoiced,
  completed,
  pending,
  cancelled
}

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.invoiced:
        return 'Invoiced';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.pending:
        return 'Pending';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case ProjectStatus.active:
        return Colors.blue;
      case ProjectStatus.invoiced:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.pending:
        return Colors.amber;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }
}

class JobCostReportData {
  final String jobId;
  final String quotationNumber;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String projectDescription;
  final DateTime startDate;
  final DateTime? endDate;
  final ProjectStatus status;
  final List<JobCostItem> items;
  final List<LaborCost> laborCosts;
  final List<AdditionalCost> additionalCosts;
  final double advanceReceived;
  final double totalInvoiced;

  JobCostReportData({
    required this.jobId,
    required this.quotationNumber,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.projectDescription,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.items,
    this.laborCosts = const [],
    this.additionalCosts = const [],
    this.advanceReceived = 0,
    this.totalInvoiced = 0,
  });

  double get totalMaterialCost {
    return items.fold(0, (sum, item) => sum + item.totalCost);
  }

  double get totalLaborCost {
    return laborCosts.fold(0, (sum, labor) => sum + labor.totalCost);
  }

  double get totalAdditionalCost {
    return additionalCosts.fold(0, (sum, cost) => sum + cost.amount);
  }

  double get totalCost {
    return totalMaterialCost + totalLaborCost + totalAdditionalCost;
  }

  double get totalSellingPrice {
    return items.fold(0, (sum, item) => sum + item.totalSellingPrice);
  }

  double get grossProfit {
    return totalSellingPrice - totalMaterialCost;
  }

  double get netProfit {
    return totalInvoiced - totalCost;
  }

  double get profitMargin {
    if (totalInvoiced == 0) return 0;
    return (netProfit / totalInvoiced) * 100;
  }

  bool get hasPendingCosts {
    return items.any((item) => item.costPrice == null || item.costPrice == 0);
  }
}

class JobCostItem {
  final String itemCode;
  final String description;
  final double quantity;
  final String unit;
  final double? costPrice; // null means pending
  final double sellingPrice;
  final String? supplier;
  final String? remarks;

  JobCostItem({
    required this.itemCode,
    required this.description,
    required this.quantity,
    required this.unit,
    this.costPrice,
    required this.sellingPrice,
    this.supplier,
    this.remarks,
  });

  double get totalCost => (costPrice ?? 0) * quantity;
  double get totalSellingPrice => sellingPrice * quantity;
  double get itemProfit => totalSellingPrice - totalCost;
  bool get isCostPending => costPrice == null || costPrice == 0;
}

class LaborCost {
  final String description;
  final String workerName;
  final double days;
  final double dailyRate;
  final DateTime? date;

  LaborCost({
    required this.description,
    required this.workerName,
    required this.days,
    required this.dailyRate,
    this.date,
  });

  double get totalCost => days * dailyRate;
}

class AdditionalCost {
  final String description;
  final double amount;
  final String category; // transport, tools, etc.
  final DateTime? date;

  AdditionalCost({
    required this.description,
    required this.amount,
    required this.category,
    this.date,
  });
}

class CompanyInfo {
  static const String name = "IMMENSE HOME PRIVATE LIMITED";
  static const String tagline = "Your Trusted Partner in Quality Construction";

  static const String address1 = "No. 123, Pagoda Road, Nugegoda";
  static const String address2 = "No. 456, Main Street, Matara";

  static const String phone = "077 586 70 80";
  static const String email = "immensehomeprivatelimited@gmail.com";
  static const String website = "www.immensehome.lk";

  static const String registrationNo = "PV 00123456";
}
