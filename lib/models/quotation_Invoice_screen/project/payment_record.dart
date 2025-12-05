class PaymentRecord {
  final double amount;
  final DateTime date;
  final String description;

  PaymentRecord(
    this.amount,
    this.date, {
    this.description = 'Payment',
  });
}