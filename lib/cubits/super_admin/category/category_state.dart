import '../../../models/category_model.dart';

class CategoryState {
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? errorMessage;
  final CategoryModel? selectedCategory;
  final Map<String, dynamic>? itemConfigs;

  CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory,
    this.itemConfigs,
  });

  CategoryState copyWith({
    List<CategoryModel>? categories,
    bool? isLoading,
    String? errorMessage,
    CategoryModel? selectedCategory,
    Map<String, dynamic>? itemConfigs,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      itemConfigs: itemConfigs ?? this.itemConfigs,
    );
  }
}
