import '../../models/category_model.dart';
import '../../services/super_admin/category_api_service.dart';

class CategoryRepository {
  final CategoryApiService _categoryApiService;

  CategoryRepository() : _categoryApiService = CategoryApiService();

  // =================== CONFIGURATIONS ===================

  // GET: Fetch item configurations
  Future<Map<String, dynamic>> fetchItemConfigs({String? token}) async {
    try {
      final response = await _categoryApiService.getItemConfigs(token: token);
      return response['data'];
    } catch (e) {
      throw Exception('Failed to fetch item configurations: $e');
    }
  }

  // =================== CATEGORY METHODS ===================

  // GET: Fetch all categories
  Future<List<CategoryModel>> fetchCategories({String? token, String? companyId}) async {
    try {
      final response = await _categoryApiService.getCategories(token: token, companyId: companyId);
      final List data = response['data'] ?? [];

      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // POST: Create new category
  Future<CategoryModel> createCategory(String name, {String? token, String? companyId}) async {
    try {
      final response = await _categoryApiService.createCategory(name, token: token, companyId: companyId);
      final data = response['data'];

      return CategoryModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // PUT: Update category
  Future<CategoryModel> updateCategory(String id, String name, {String? token}) async {
    try {
      final response = await _categoryApiService.updateCategory(id, name, token: token);
      final data = response['data'];

      return CategoryModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // DELETE: Delete category
  Future<void> deleteCategory(String id, {String? token}) async {
    try {
      await _categoryApiService.deleteCategory(id, token: token);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // =================== ITEM METHODS ===================

  // POST: Add item to category
  Future<ItemModel> addItemToCategory(
    String categoryId,
    String itemName,
    String baseUnit,
    String? packagingUnit,
    double sqftPerUnit,
    bool isService,
    String? pricingType, {
    String? token
  }) async {
    try {
      final response = await _categoryApiService.addItemToCategory(
        categoryId,
        itemName,
        baseUnit,
        packagingUnit,
        sqftPerUnit,
        isService,
        pricingType,
        token: token,
      );
      final data = response['data'];

      return ItemModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  // PUT: Update item
  Future<ItemModel> updateItem(
    String categoryId,
    String itemId,
    String itemName,
    String baseUnit,
    String? packagingUnit,
    double sqftPerUnit,
    bool isService,
    String? pricingType, {
    String? token
  }) async {
    try {
      final response = await _categoryApiService.updateItem(
        categoryId,
        itemId,
        itemName,
        baseUnit,
        packagingUnit,
        sqftPerUnit,
        isService,
        pricingType,
        token: token,
      );
      final data = response['data'];

      return ItemModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // DELETE: Delete item
  Future<void> deleteItem(String categoryId, String itemId, {String? token}) async {
    try {
      await _categoryApiService.deleteItem(categoryId, itemId, token: token);
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }
}
