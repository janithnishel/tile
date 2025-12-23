// Category and Item Models for Flutter App

class CategoryModel {
  final String id;
  final String name;
  final String companyId;
  final List<ItemModel> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.companyId,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      companyId: json['companyId'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => ItemModel.fromJson(item))
          .toList() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'companyId': companyId,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? companyId,
    List<ItemModel>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      companyId: companyId ?? this.companyId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum ServicePricingType {
  fixed,
  variable,
}

class ItemModel {
  final String id;
  final String itemName;
  final String baseUnit;
  final String? packagingUnit;
  final double sqftPerUnit;
  final String categoryId;
  final bool isService;
  final ServicePricingType? pricingType;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.baseUnit,
    this.packagingUnit,
    required this.sqftPerUnit,
    required this.categoryId,
    this.isService = false,
    this.pricingType,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    ServicePricingType? pricingType;
    if (json['pricingType'] != null) {
      switch (json['pricingType']) {
        case 'fixed':
          pricingType = ServicePricingType.fixed;
          break;
        case 'variable':
          pricingType = ServicePricingType.variable;
          break;
      }
    }

    return ItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      itemName: json['itemName'] ?? '',
      baseUnit: json['baseUnit'] ?? '',
      packagingUnit: json['packagingUnit'],
      sqftPerUnit: (json['sqftPerUnit'] ?? 0).toDouble(),
      categoryId: json['categoryId'] ?? '',
      isService: json['isService'] ?? false,
      pricingType: pricingType,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_id': id,
      'itemName': itemName,
      'baseUnit': baseUnit,
      'sqftPerUnit': sqftPerUnit,
      'categoryId': categoryId,
      'isService': isService,
    };

    if (packagingUnit != null) {
      data['packagingUnit'] = packagingUnit;
    }

    if (pricingType != null) {
      data['pricingType'] = pricingType == ServicePricingType.fixed ? 'fixed' : 'variable';
    }

    return data;
  }

  ItemModel copyWith({
    String? id,
    String? itemName,
    String? baseUnit,
    String? packagingUnit,
    double? sqftPerUnit,
    String? categoryId,
    bool? isService,
    ServicePricingType? pricingType,
  }) {
    return ItemModel(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      baseUnit: baseUnit ?? this.baseUnit,
      packagingUnit: packagingUnit ?? this.packagingUnit,
      sqftPerUnit: sqftPerUnit ?? this.sqftPerUnit,
      categoryId: categoryId ?? this.categoryId,
      isService: isService ?? this.isService,
      pricingType: pricingType ?? this.pricingType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Request/Response Models for API
class CreateCategoryRequest {
  final String name;

  CreateCategoryRequest({required this.name});

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class UpdateCategoryRequest {
  final String name;

  UpdateCategoryRequest({required this.name});

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class CreateItemRequest {
  final String itemName;
  final String baseUnit;
  final double sqftPerUnit;

  CreateItemRequest({
    required this.itemName,
    required this.baseUnit,
    required this.sqftPerUnit,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'baseUnit': baseUnit,
      'sqftPerUnit': sqftPerUnit,
    };
  }
}

class UpdateItemRequest {
  final String itemName;
  final String baseUnit;
  final double sqftPerUnit;

  UpdateItemRequest({
    required this.itemName,
    required this.baseUnit,
    required this.sqftPerUnit,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'baseUnit': baseUnit,
      'sqftPerUnit': sqftPerUnit,
    };
  }
}

// ═══════════════════════════════════════
// 🏷️ ITEM TEMPLATE MODEL (for Admin Template Management)
// ═══════════════════════════════════════

class ItemTemplateModel {
  final String id;
  final String itemName;
  final String baseUnit;
  final String? packagingUnit;
  final double? sqftPerUnit;
  final String categoryId;
  final bool isService;
  final ServicePricingType? pricingType;

  ItemTemplateModel({
    required this.id,
    required this.itemName,
    required this.baseUnit,
    this.packagingUnit,
    this.sqftPerUnit,
    required this.categoryId,
    this.isService = false,
    this.pricingType,
  });

  // Factory constructor for JSON deserialization
  factory ItemTemplateModel.fromJson(Map<String, dynamic> json) {
    ServicePricingType? pricingType;
    if (json['pricingType'] != null) {
      switch (json['pricingType']) {
        case 'fixed':
          pricingType = ServicePricingType.fixed;
          break;
        case 'variable':
          pricingType = ServicePricingType.variable;
          break;
      }
    }

    return ItemTemplateModel(
      id: json['_id'] ?? json['id'] ?? '',
      itemName: json['itemName'] ?? '',
      baseUnit: json['baseUnit'] ?? '',
      packagingUnit: json['packagingUnit'],
      sqftPerUnit: json['sqftPerUnit'] != null ? (json['sqftPerUnit'] as num).toDouble() : null,
      categoryId: json['categoryId'] ?? '',
      isService: json['isService'] ?? false,
      pricingType: pricingType,
    );
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_id': id,
      'itemName': itemName,
      'baseUnit': baseUnit,
      'categoryId': categoryId,
      'isService': isService,
    };

    if (packagingUnit != null) {
      data['packagingUnit'] = packagingUnit;
    }

    if (sqftPerUnit != null) {
      data['sqftPerUnit'] = sqftPerUnit;
    }

    if (pricingType != null) {
      data['pricingType'] = pricingType == ServicePricingType.fixed ? 'fixed' : 'variable';
    }

    return data;
  }

  // Copy with method for immutability
  ItemTemplateModel copyWith({
    String? id,
    String? itemName,
    String? baseUnit,
    String? packagingUnit,
    double? sqftPerUnit,
    String? categoryId,
    bool? isService,
    ServicePricingType? pricingType,
  }) {
    return ItemTemplateModel(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      baseUnit: baseUnit ?? this.baseUnit,
      packagingUnit: packagingUnit ?? this.packagingUnit,
      sqftPerUnit: sqftPerUnit ?? this.sqftPerUnit,
      categoryId: categoryId ?? this.categoryId,
      isService: isService ?? this.isService,
      pricingType: pricingType ?? this.pricingType,
    );
  }
}
