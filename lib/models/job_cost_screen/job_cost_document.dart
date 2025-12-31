import 'invoice_item.dart';
import 'po_item_cost.dart';
import 'other_expense.dart';

class JobCostDocument {
  final String? id;
  final String invoiceId;
  final String customerName;
  final String customerPhone;
  final String projectTitle;
  final DateTime invoiceDate;
  final List<InvoiceItem> invoiceItems;
  final List<POItemCost> purchaseOrderItems;
  final List<OtherExpense> otherExpenses;

  JobCostDocument({
    this.id,
    required this.invoiceId,
    required this.customerName,
    required this.customerPhone,
    required this.projectTitle,
    required this.invoiceDate,
    required this.invoiceItems,
    required this.purchaseOrderItems,
    List<OtherExpense>? otherExpenses,
  }) : otherExpenses = otherExpenses ?? [];

  // Computed Properties
  String get displayId => 'QUO-$invoiceId';

  double get totalRevenue =>
      invoiceItems.fold(0, (sum, item) => sum + item.totalSellingPrice);

  double get materialCost =>
      invoiceItems.fold(0, (sum, item) => sum + item.totalCostPrice);

  double get purchaseOrderCost =>
      purchaseOrderItems.fold(0, (sum, item) => sum + item.totalCost);

  double get otherExpensesCost =>
      otherExpenses.fold(0, (sum, item) => sum + item.amount);

  double get totalCost => materialCost + purchaseOrderCost + otherExpensesCost;

  double get profit => totalRevenue - totalCost;

  double get profitMargin =>
      totalRevenue > 0 ? (profit / totalRevenue) * 100 : 0;

  double get invoiceItemsProfit =>
      invoiceItems.fold<double>(0, (sum, item) => sum + item.profit);

  bool get isProfitable => profit >= 0;

  // Helper Methods
  void addExpense(OtherExpense expense) {
    otherExpenses.add(expense);
  }

  // JSON serialization
  factory JobCostDocument.fromJson(Map<String, dynamic> json) {
    return JobCostDocument(
      id: json['_id'] as String?,
      invoiceId: json['invoiceId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String? ?? '',
      projectTitle: json['projectTitle'] as String,
      invoiceDate: DateTime.parse(json['invoiceDate'] as String),
      invoiceItems: (json['invoiceItems'] as List<dynamic>?)
          ?.map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      purchaseOrderItems: (json['purchaseOrderItems'] as List<dynamic>?)
          ?.map((item) => POItemCost.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      otherExpenses: (json['otherExpenses'] as List<dynamic>?)
          ?.map((item) => OtherExpense.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'invoiceId': invoiceId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'projectTitle': projectTitle,
      'invoiceDate': invoiceDate.toIso8601String(),
      'invoiceItems': invoiceItems.map((item) => item.toJson()).toList(),
      'purchaseOrderItems': purchaseOrderItems.map((item) => item.toJson()).toList(),
      'otherExpenses': otherExpenses.map((item) => item.toJson()).toList(),
    };
  }
}
