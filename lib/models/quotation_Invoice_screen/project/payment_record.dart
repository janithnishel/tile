class PaymentRecord {
  final double amount;
  final DateTime date;
  final String description;

  PaymentRecord(
    this.amount,
    this.date, {
    this.description = 'Payment',
  });

  // Factory constructor for JSON deserialization
  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      (json['amount'] as num?)?.toDouble() ?? 0.0,
      DateTime.parse(json['date'] as String? ?? DateTime.now().toIso8601String()),
      description: json['description'] as String? ?? 'Payment',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
