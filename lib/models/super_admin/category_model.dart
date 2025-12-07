// lib/models/category_model.dart

class CategoryModel {
  final String id;
  final String name;
  final String companyId;
  final List<ItemTemplateModel> items;

  CategoryModel({
    required this.id,
    required this.name,
    required this.companyId,
    this.items = const [],
  });
}

class ItemTemplateModel {
  final String id;
  final String itemName;
  final String baseUnit;
  final double sqftPerUnit;
  final String categoryId;

  ItemTemplateModel({
    required this.id,
    required this.itemName,
    required this.baseUnit,
    required this.sqftPerUnit,
    required this.categoryId,
  });
}