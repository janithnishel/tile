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
}

class ItemModel {
  final String id;
  final String itemName;
  final String baseUnit;
  final String? packagingUnit;
  final double sqftPerUnit;
  final String categoryId;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.baseUnit,
    this.packagingUnit,
    required this.sqftPerUnit,
    required this.categoryId,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      itemName: json['itemName'] ?? '',
      baseUnit: json['baseUnit'] ?? '',
      packagingUnit: json['packagingUnit'],
      sqftPerUnit: (json['sqftPerUnit'] ?? 0).toDouble(),
      categoryId: json['categoryId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_id': id,
      'itemName': itemName,
      'baseUnit': baseUnit,
      'sqftPerUnit': sqftPerUnit,
      'categoryId': categoryId,
    };

    if (packagingUnit != null) {
      data['packagingUnit'] = packagingUnit;
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
  }) {
    return ItemModel(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      baseUnit: baseUnit ?? this.baseUnit,
      packagingUnit: packagingUnit ?? this.packagingUnit,
      sqftPerUnit: sqftPerUnit ?? this.sqftPerUnit,
      categoryId: categoryId ?? this.categoryId,
    );
  }
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
