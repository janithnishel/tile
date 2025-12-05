class ItemDescription {
  final String name;
  final double sellingPrice;
  final String unit;

  ItemDescription(
    this.name, {
    required this.sellingPrice,
    this.unit = 'units',
  });

  // Copy with method for immutability
  ItemDescription copyWith({
    String? name,
    double? sellingPrice,
    String? unit,
  }) {
    return ItemDescription(
      name ?? this.name,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      unit: unit ?? this.unit,
    );
  }
}