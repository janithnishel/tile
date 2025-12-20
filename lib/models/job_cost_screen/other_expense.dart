class OtherExpense {
  final String category;
  final String description;
  final double amount;
  final DateTime date;

  OtherExpense({
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  OtherExpense copyWith({
    String? category,
    String? description,
    double? amount,
    DateTime? date,
  }) {
    return OtherExpense(
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  // JSON serialization
  factory OtherExpense.fromJson(Map<String, dynamic> json) {
    return OtherExpense(
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
