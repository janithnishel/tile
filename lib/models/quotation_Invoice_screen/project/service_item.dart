enum UnitType { fixed, sqft, ft }

class ServiceItem {
  String serviceDescription;
  UnitType unitType;
  double quantity;
  double rate;
  bool isAlreadyPaid; // For site visits

  ServiceItem({
    required this.serviceDescription,
    this.unitType = UnitType.fixed,
    this.quantity = 1.0,
    this.rate = 0.0,
    this.isAlreadyPaid = false,
  });

  // Factory constructor for JSON deserialization
  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    final unitTypeStr = json['unitType'] as String?;
    UnitType unitType = UnitType.fixed;
    if (unitTypeStr == 'sqft') {
      unitType = UnitType.sqft;
    } else if (unitTypeStr == 'ft') {
      unitType = UnitType.ft;
    }

    return ServiceItem(
      serviceDescription: json['serviceDescription'] as String? ?? '',
      unitType: unitType,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      isAlreadyPaid: json['isAlreadyPaid'] as bool? ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    String unitTypeStr = 'fixed';
    if (unitType == UnitType.sqft) {
      unitTypeStr = 'sqft';
    } else if (unitType == UnitType.ft) {
      unitTypeStr = 'ft';
    }

    return {
      'serviceDescription': serviceDescription,
      'unitType': unitTypeStr,
      'quantity': quantity,
      'rate': rate,
      'isAlreadyPaid': isAlreadyPaid,
    };
  }

  double get amount => quantity * rate;

  // For display purposes
  String get unitTypeDisplay {
    switch (unitType) {
      case UnitType.fixed:
        return 'Fixed';
      case UnitType.sqft:
        return 'sqft';
      case UnitType.ft:
        return 'ft';
    }
  }
}
