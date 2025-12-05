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
}