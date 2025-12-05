import 'invoice_item.dart';
import 'po_item_cost.dart';
import 'other_expense.dart';

class JobCostDocument {
  final String invoiceId;
  final String customerName;
  final String customerPhone;
  final String projectTitle;
  final DateTime invoiceDate;
  final List<InvoiceItem> invoiceItems;
  final List<POItemCost> purchaseOrderItems;
  final List<OtherExpense> otherExpenses;

  JobCostDocument({
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
  String get displayId => 'INV-$invoiceId';

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
}