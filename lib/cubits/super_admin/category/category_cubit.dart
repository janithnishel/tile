import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/category_model.dart';
import '../../../repositories/super_admin/category_repository.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryCubit(this._categoryRepository) : super(CategoryState());

  // Helper method to get token from AuthCubit
  String? _getToken(BuildContext context) {
    // This will be called from the UI layer where AuthCubit is available
    // For now, we'll pass token as parameter to methods
    return null;
  }

  // =================== CATEGORY OPERATIONS ===================

  // 1. Load Categories
  Future<void> loadCategories({String? token}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final categories = await _categoryRepository.fetchCategories(token: token);
      emit(state.copyWith(categories: categories, isLoading: false));
    } catch (e) {
      debugPrint('💥 CategoryCubit: Failed to load categories: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load categories.',
      ));
    }
  }

  // 2. Create Category
  Future<void> createCategory(String name, {String? token}) async {
    try {
      final newCategory = await _categoryRepository.createCategory(name, token: token);
      final updatedCategories = [...state.categories, newCategory];
      emit(state.copyWith(categories: updatedCategories));
    } catch (e) {
      debugPrint('💥 CategoryCubit: Failed to create category: $e');
      emit(state.copyWith(errorMessage: 'Failed to create category.'));
      rethrow;
    }
  }

  // 3. Update Category
  Future<void> updateCategory(String id, String name, {String? token}) async {
    try {
      final updatedCategory = await _categoryRepository.updateCategory(id, name, token: token);
      final updatedCategories = state.categories.map((category) {
        return category.id == id ? updatedCategory : category;
      }).toList();
      emit(state.copyWith(categories: updatedCategories));
    } catch (e) {
      debugPrint('💥 CategoryCubit: Failed to update category: $e');
      emit(state.copyWith(errorMessage: 'Failed to update category.'));
      rethrow;
    }
  }

  // 4. Delete Category
  Future<void> deleteCategory(String id, {String? token}) async {
    try {
      await _categoryRepository.deleteCategory(id, token: token);
      final updatedCategories = state.categories.where((category) => category.id != id).toList();
      emit(state.copyWith(categories: updatedCategories));
    } catch (e) {
      debugPrint('💥 CategoryCubit: Failed to delete category: $e');
      emit(state.copyWith(errorMessage: 'Failed to delete category.'));
      rethrow;
    }
  }

  // =================== ITEM OPERATIONS ===================

  // 5. Add Item to Category
  Future<void> addItemToCategory(
    String categoryId,
    String itemName,
    String baseUnit,
    double sqftPerUnit, {
    String? token
  }) async {
    try {
      final newItem = await _categoryRepository.addItemToCategory(
        categoryId,
        itemName,
        baseUnit,
        sqftPerUnit,
        token: token,
      );

      final updatedCategories = state.categories.map((category) {
        if (category.id == categoryId) {
          final updatedItems = [...category.items, newItem];
          return category.copyWith(items: updatedItems);
        }
        return category;
      }).toList();

      emit(state.copyWith(categories: updatedCategories));
    } catch (e) {
      debugPrint('💥 CategoryCubit: Failed to add item: $e');
      emit(state.copyWith(errorMessage: 'Failed to add item.'));
      rethrow;
    }
  }

  // 6. Update Item
  Future<void> updateItem(
    String categoryId,
    String itemId,
    String itemName,
    String baseUnit,
    double sqftPerUnit, {
    String? token
  }) async {
    try {
      final updatedItem = await _categoryRepository.updateItem(
        categoryId,
        itemId,
        itemName,
        baseUnit,
        sqftPerUnit,
        token: token,
      );

      final updatedCategories = state.categories.map((category) {
        if (category.id == categoryId) {
          final updatedItems = category.items.map((item) {
            return item.id == itemId ? updatedItem : item;
          }).toList();
          return category.copyWith(items: updatedItems);
        }
        return category;
      }).toList();

      emit(state.copyWith(categories: updatedCategories));
    } catch (e) {
      debugPrint('💥 CategoryCubit: Failed to update item: $e');
      emit(state.copyWith(errorMessage: 'Failed to update item.'));
      rethrow;
    }
  }

  // 7. Delete Item
  Future<void> deleteItem(String categoryId, String itemId, {String? token}) async {
    try {
      await _categoryRepository.deleteItem(categoryId, itemId, token: token);

      final updatedCategories = state.categories.map((category) {
        if (category.id == categoryId) {
          final updatedItems = category.items.where((item) => item.id != itemId).toList();
          return category.copyWith(items: updatedItems);
        }
        return category;
      }).toList();

      emit(state.copyWith(categories: updatedCategories));
    } catch (e) {
      debugPrint('💥 CategoryCubit: Failed to delete item: $e');
      emit(state.copyWith(errorMessage: 'Failed to delete item.'));
      rethrow;
    }
  }

  // =================== UTILITY METHODS ===================

  // Select Category
  void selectCategory(CategoryModel? category) {
    emit(state.copyWith(selectedCategory: category));
  }

  // Clear Error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
