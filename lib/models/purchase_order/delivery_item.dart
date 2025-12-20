// lib/models/purchase_order/delivery_item.dart

class DeliveryItem {
  final String itemId;
  final String itemName;
  final double orderedQuantity;
  final double receivedQuantity;
  final bool isVerified;
  final String? notes;
  final DateTime? verifiedAt;

  DeliveryItem({
    required this.itemId,
    required this.itemName,
    required this.orderedQuantity,
    this.receivedQuantity = 0,
    this.isVerified = false,
    this.notes,
    this.verifiedAt,
  });

  bool get isFullyReceived => receivedQuantity >= orderedQuantity;
  bool get isPartiallyReceived => receivedQuantity > 0 && receivedQuantity < orderedQuantity;
  double get shortageQuantity => orderedQuantity - receivedQuantity;

  DeliveryItem copyWith({
    String? itemId,
    String? itemName,
    double? orderedQuantity,
    double? receivedQuantity,
    bool? isVerified,
    String? notes,
    DateTime? verifiedAt,
  }) {
    return DeliveryItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      orderedQuantity: orderedQuantity ?? this.orderedQuantity,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
      isVerified: isVerified ?? this.isVerified,
      notes: notes ?? this.notes,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'orderedQuantity': orderedQuantity,
      'receivedQuantity': receivedQuantity,
      'isVerified': isVerified,
      'notes': notes,
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      itemId: json['itemId'] ?? '',
      itemName: json['itemName'] ?? '',
      orderedQuantity: (json['orderedQuantity'] ?? 0).toDouble(),
      receivedQuantity: (json['receivedQuantity'] ?? 0).toDouble(),
      isVerified: json['isVerified'] ?? false,
      notes: json['notes'],
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
    );
  }
}