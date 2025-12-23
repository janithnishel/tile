import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/super_admin/category/category_cubit.dart';
import 'package:tilework/cubits/super_admin/category/category_state.dart';
import 'package:tilework/cubits/super_admin/dashboard/dashboard_cubit.dart';
import 'package:tilework/models/category_model.dart';
import 'package:tilework/models/company_model.dart';
import 'package:tilework/theme/theme.dart';
import 'package:tilework/widget/super_admin/app_button.dart';
import 'package:tilework/widget/super_admin/app_card.dart';
import 'package:tilework/widget/super_admin/app_text_field.dart';
import 'package:tilework/widget/super_admin/dialogs/confirm_dialog.dart';
import 'package:tilework/widget/super_admin/section_header.dart';

class CompanySetupScreen extends StatefulWidget {
  final CompanyModel company;
  final VoidCallback onBack;

  const CompanySetupScreen({
    Key? key,
    required this.company,
    required this.onBack,
  }) : super(key: key);

  @override
  State<CompanySetupScreen> createState() => _CompanySetupScreenState();
}

class _CompanySetupScreenState extends State<CompanySetupScreen> {
  @override
  void initState() {
    super.initState();
    // Load categories and item configurations when screen opens
    final token = _getToken();
    if (token != null) {
      context.read<CategoryCubit>().loadCategories(token: token, companyId: widget.company.id);
      context.read<CategoryCubit>().loadItemConfigs(token: token);
    }
  }

  String? _getToken() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      return authState.token;
    }
    return null;
  }

  // Get default pricing type based on base unit selection
  String? _getDefaultPricingType(String? baseUnit, bool isService) {
    if (!isService || baseUnit == null) return null;

    // Service pricing logic
    if (['sqft', 'ft'].contains(baseUnit)) {
      return 'variable'; // Area-based services default to variable pricing
    } else if (['Job', 'Visit'].contains(baseUnit)) {
      return 'fixed'; // One-time services default to fixed pricing
    }

    return 'variable'; // Default fallback
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        return Column(
          children: [
            // ═══════════════════════════════════════
            // 🔝 HEADER WITH BACK BUTTON
            // ═══════════════════════════════════════
            _buildHeader(),

            // ═══════════════════════════════════════
            // 📋 SETUP CONTENT
            // ═══════════════════════════════════════
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Info Card
                    _buildCompanyInfoCard(state.categories.length),

                    const SizedBox(height: 32),

                    // Category Setup
                    SectionHeader(
                      title: 'Category Setup',
                      subtitle: 'Manage product categories for this company',
                      icon: Icons.category_rounded,
                      action: AppButton(
                        text: 'Add Category',
                        icon: Icons.add_rounded,
                        type: AppButtonType.secondary,
                        onPressed: _showAddCategoryDialog,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Loading state
                    if (state.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (state.categories.isEmpty)
                      _buildEmptyCategoryState()
                    else
                      _buildCategoriesGrid(state.categories),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════
  // 🔝 HEADER
  // ═══════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
          ),
          const SizedBox(width: 16),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.company.companyName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.company.companyName, style: AppTheme.heading2),
                Text(
                  'Owner: ${widget.company.ownerName} • ${widget.company.ownerEmail}',
                  style: AppTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: widget.company.isActive
                  ? AppTheme.success.withOpacity(0.1)
                  : AppTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  widget.company.isActive
                      ? Icons.check_circle_rounded
                      : Icons.pause_circle_rounded,
                  size: 16,
                  color: widget.company.isActive
                      ? AppTheme.success
                      : AppTheme.warning,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.company.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: widget.company.isActive
                        ? AppTheme.success
                        : AppTheme.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // 📄 COMPANY INFO CARD
  // ═══════════════════════════════════════
  Widget _buildCompanyInfoCard(int categoryCount) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: _buildInfoItem(
              Icons.location_on_outlined,
              'Address',
              widget.company.companyAddress,
            ),
          ),
          Container(width: 1, height: 50, color: AppTheme.border),
          Expanded(
            child: _buildInfoItem(
              Icons.phone_outlined,
              'Company Phone',
              widget.company.companyPhone,
            ),
          ),
          Container(width: 1, height: 50, color: AppTheme.border),
          Expanded(
            child: _buildInfoItem(
              Icons.person_outline,
              'Owner Phone',
              widget.company.ownerPhone,
            ),
          ),
          Container(width: 1, height: 50, color: AppTheme.border),
          Expanded(
            child: _buildInfoItem(
              Icons.category_outlined,
              'Categories',
              '$categoryCount categories',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // 🔲 EMPTY STATE
  // ═══════════════════════════════════════
  Widget _buildEmptyCategoryState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No categories yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first category to get started',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          AppButton(
            text: 'Add Category',
            icon: Icons.add_rounded,
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // 📦 CATEGORIES GRID
  // ═══════════════════════════════════════
  Widget _buildCategoriesGrid(List<CategoryModel> categories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final cardMinWidth = 200.0;
        final crossAxisCount = (availableWidth / cardMinWidth).floor().clamp(1, 4);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: crossAxisCount <= 2 ? 1.8 : 1.5,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryCard(categories[index]);
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════
  // 📦 CATEGORY CARD
  // ═══════════════════════════════════════
  Widget _buildCategoryCard(CategoryModel category) {
    return AppCard(
      onTap: () => _showItemManagementDialog(category),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: AppTheme.primaryAccent,
                  size: 22,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: category.items.isNotEmpty
                      ? AppTheme.success.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category.items.length} items',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: category.items.isNotEmpty ? AppTheme.success : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _buildCardAction(
                icon: Icons.edit_outlined,
                color: AppTheme.primaryAccent,
                onTap: () => _showEditCategoryDialog(category),
              ),
              _buildCardAction(
                icon: Icons.delete_outline,
                color: AppTheme.error,
                onTap: () => _showDeleteCategoryDialog(category),
              ),
            ],
          ),
          const Spacer(),
          Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Click to manage items',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildCardAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  // ═══════════════════════════════════════
  // ➕ ADD CATEGORY DIALOG
  // ═══════════════════════════════════════
  Future<void> _showAddCategoryDialog() async {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Add New Category', style: AppTheme.heading3),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Category Name',
                    hint: 'Enter category name (e.g., LVT, Ceramic)',
                    controller: nameController,
                    prefixIcon: Icons.category_outlined,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Category name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancel',
                          type: AppButtonType.outlined,
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Add Category',
                          icon: Icons.add_rounded,
                          isLoading: isLoading,
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() => isLoading = true);
                              try {
                                final token = _getToken();
                                await context.read<CategoryCubit>().createCategory(
                                  nameController.text.trim(),
                                  token: token,
                                  companyId: widget.company.id,
                                );
                                Navigator.pop(dialogContext);

                                // Refresh dashboard data for real-time updates
                                if (token != null) {
                                  context.read<DashboardCubit>().refreshData(token: token);
                                }

                                _showSuccessSnackBar('Category added successfully!');
                              } catch (e) {
                                _showErrorSnackBar('Failed to add category: ${e.toString()}');
                              }
                              setState(() => isLoading = false);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // ✏️ EDIT CATEGORY DIALOG
  // ═══════════════════════════════════════
  Future<void> _showEditCategoryDialog(CategoryModel category) async {
    final nameController = TextEditingController(text: category.name);
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: AppTheme.primaryAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Edit Category', style: AppTheme.heading3),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Category Name',
                    hint: 'Enter category name',
                    controller: nameController,
                    prefixIcon: Icons.category_outlined,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Category name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancel',
                          type: AppButtonType.outlined,
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Update',
                          icon: Icons.check_rounded,
                          isLoading: isLoading,
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() => isLoading = true);
                              try {
                                final token = _getToken();
                                await context.read<CategoryCubit>().updateCategory(
                                  category.id,
                                  nameController.text.trim(),
                                  token: token,
                                );
                                Navigator.pop(dialogContext);

                                // Refresh dashboard data for real-time updates
                                if (token != null) {
                                  context.read<DashboardCubit>().refreshData(token: token);
                                }

                                _showSuccessSnackBar('Category updated successfully!');
                              } catch (e) {
                                _showErrorSnackBar('Failed to update category: ${e.toString()}');
                              }
                              setState(() => isLoading = false);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // 🗑️ DELETE CATEGORY DIALOG
  // ═══════════════════════════════════════
  Future<void> _showDeleteCategoryDialog(CategoryModel category) async {
    final result = await ConfirmDialog.show(
      context: context,
      title: 'Delete Category',
      message: 'Are you sure you want to delete "${category.name}"?\n\nAll items in this category will also be deleted.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_forever_rounded,
      isDanger: true,
    );

    if (result == true) {
      try {
        final token = _getToken();
        await context.read<CategoryCubit>().deleteCategory(category.id, token: token);

        // Refresh dashboard data for real-time updates
        if (token != null) {
          context.read<DashboardCubit>().refreshData(token: token);
        }

        _showSuccessSnackBar('Category "${category.name}" deleted successfully!');
      } catch (e) {
        _showErrorSnackBar('Failed to delete category: ${e.toString()}');
      }
    }
  }

  // ═══════════════════════════════════════
  // 📦 ITEM MANAGEMENT DIALOG
  // ═══════════════════════════════════════
  Future<void> _showItemManagementDialog(CategoryModel category) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<CategoryCubit, CategoryState>(
        builder: (dialogContext, state) {
          // Find the updated category from the current state
          final updatedCategory = state.categories.firstWhere(
            (cat) => cat.id == category.id,
            orElse: () => category, // Fallback to original category if not found
          );

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radiusLg),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.inventory_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${updatedCategory.name} - Items',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${updatedCategory.items.length} items',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Add Item Button
                          AppButton(
                            text: 'Add Item',
                            icon: Icons.add_rounded,
                            type: AppButtonType.secondary,
                            onPressed: () => _showAddItemDialog(dialogContext, updatedCategory),
                          ),
                          const SizedBox(height: 20),

                          // Items List
                          if (updatedCategory.items.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 48,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No items in this category',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...updatedCategory.items.map((item) => _buildItemTile(item, updatedCategory, dialogContext)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemTile(ItemModel item, CategoryModel category, BuildContext dialogContext) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppTheme.primaryAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Unit: ${item.baseUnit}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Sqft/Unit: ${item.sqftPerUnit}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditItemDialog(dialogContext, item, category),
            icon: const Icon(Icons.edit_outlined),
            color: AppTheme.primaryAccent,
          ),
          IconButton(
            onPressed: () => _showDeleteItemDialog(item, category),
            icon: const Icon(Icons.delete_outline),
            color: AppTheme.error,
          ),
        ],
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext dialogContext, CategoryModel category) async {
    final itemNameController = TextEditingController();
    final sqftController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    // Item type toggle
    bool isService = false;
    String? selectedPricingType;

    // Get item configs from state
    final itemConfigs = BlocProvider.of<CategoryCubit>(context).state.itemConfigs;

    // Helper function to get base units based on item type
    List<String> getBaseUnits(bool isServiceType) {
      if (isServiceType) {
        // For services, only allow these units
        return ['fixed', 'ft', 'sqft'];
      }

      final dynamic configUnits = itemConfigs?['unit_configs']?['product_units'];
      final List<String> defaultUnits = ['sqft', 'ft', 'pcs', 'kg', 'm'];
      final List<String> raw = configUnits is List ? List<String>.from(configUnits) : defaultUnits;
      return LinkedHashSet<String>.from(raw).toList();
    }

    String? selectedBaseUnit;

    // Packaging unit options and state
    final List<String> packagingUnits = ['None', 'Box', 'Roll', 'Sheet', 'Pcs', 'Strip'];
    String? selectedPackagingUnit = 'None';

    await showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (itemDialogContext) => StatefulBuilder(
        builder: (itemDialogContext, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Add New Item', style: AppTheme.heading3),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Item Name',
                    hint: 'Enter item name',
                    controller: itemNameController,
                    prefixIcon: Icons.inventory_2_outlined,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Item name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Item Type Toggle
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Item Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('Product'),
                                value: false,
                                groupValue: isService,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      isService = value;
                                      selectedPricingType = null;
                                      // Clear service-related fields when switching to product
                                      if (!value) {
                                        selectedPackagingUnit = 'None';
                                      }
                                    });
                                  }
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('Service'),
                                value: true,
                                groupValue: isService,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      isService = value;
                                      selectedPricingType = null;
                                      // Clear product-related fields when switching to service
                                      if (value) {
                                        selectedPackagingUnit = 'None';
                                      }
                                    });
                                  }
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Base Unit Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Base Unit',
                        style: AppTheme.labelText,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedBaseUnit,
                          decoration: InputDecoration(
                            hintText: 'Select base unit',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.normal,
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.straighten_outlined,
                                color: AppTheme.primaryAccent,
                                size: 20,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          items: getBaseUnits(isService).map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedBaseUnit = value;
                              // Auto-set pricing type for services based on base unit
                              if (isService) {
                                selectedPricingType = _getDefaultPricingType(value, isService);
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Base unit is required';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Service pricing type removed - services are automatically fixed

                  // Packaging Unit Dropdown - only show when Product is selected
                  if (!isService) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Packaging Unit (Optional)',
                          style: AppTheme.labelText,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: selectedPackagingUnit,
                            decoration: InputDecoration(
                              hintText: 'Select packaging unit',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.normal,
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: AppTheme.primaryAccent,
                                  size: 20,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            items: packagingUnits.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedPackagingUnit = value;
                                // Clear sqft per unit if no packaging unit selected
                                if (value == null) {
                                  sqftController.clear();
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Sqft per Unit - only show when packaging unit is not 'None'
                    if (selectedPackagingUnit != null && selectedPackagingUnit != 'None') ...[
                      AppTextField(
                        label: selectedBaseUnit != null && selectedPackagingUnit != null
                            ? '$selectedBaseUnit per $selectedPackagingUnit'
                            : 'Sqft per Unit',
                        hint: selectedBaseUnit != null && selectedPackagingUnit != null
                            ? 'Ex: 0.33 (${selectedBaseUnit?.toLowerCase()} per ${selectedPackagingUnit?.toLowerCase()})'
                            : 'Ex: 0.33',
                        controller: sqftController,
                        prefixIcon: Icons.calculate_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Sqft per unit is required';
                          final num = double.tryParse(value!);
                          if (num == null || num <= 0) return 'Enter valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancel',
                          type: AppButtonType.outlined,
                          onPressed: () => Navigator.pop(itemDialogContext),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Add Item',
                          icon: Icons.add_rounded,
                          isLoading: isLoading,
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() => isLoading = true);
                              try {
                                final token = _getToken();
                                final packagingUnitToSend = selectedPackagingUnit == 'None' ? null : selectedPackagingUnit;
                                final sqftValue = (selectedPackagingUnit == null || selectedPackagingUnit == 'None')
                                    ? 0.0 // Default value when no packaging unit
                                    : double.parse(sqftController.text.trim());

                                await context.read<CategoryCubit>().addItemToCategory(
                                  category.id,
                                  itemNameController.text.trim(),
                                  selectedBaseUnit!,
                                  packagingUnitToSend,
                                  sqftValue,
                                  isService,
                                  selectedPricingType,
                                  token: token,
                                );

                                // Refresh dashboard data for real-time updates
                                if (token != null) {
                                  context.read<DashboardCubit>().refreshData(token: token);
                                }

                                _showSuccessSnackBar('Item added successfully!');
                                Navigator.pop(itemDialogContext); // Close dialog after successful addition
                              } catch (e) {
                                _showErrorSnackBar('Failed to add item: ${e.toString()}');
                              }
                              setState(() => isLoading = false);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditItemDialog(BuildContext dialogContext, ItemModel item, CategoryModel category) async {
    final itemNameController = TextEditingController(text: item.itemName);
    final sqftController = TextEditingController(text: item.sqftPerUnit.toString());
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    // Item type toggle
    bool isService = item.isService;
    String? selectedPricingType = item.pricingType?.name;

    // Get item configs from state
    final itemConfigs = BlocProvider.of<CategoryCubit>(context).state.itemConfigs;

    // Helper function to get base units based on item type (same as add dialog)
    List<String> getBaseUnits(bool isServiceType) {
      if (isServiceType) {
        // Restrict service units to fixed and common area units
        return ['fixed', 'ft', 'sqft'];
      }
      return itemConfigs?['unit_configs']?['product_units']?.cast<String>() ?? ['sqft', 'ft', 'pcs', 'kg', 'm'];
    }

    String? selectedBaseUnit = item.baseUnit;

    // Packaging unit options and state
    final List<String> packagingUnits = ['None', 'Box', 'Roll', 'Sheet', 'Pcs', 'Strip'];
    String? selectedPackagingUnit = (item.packagingUnit == null || item.packagingUnit == "null" || item.packagingUnit!.isEmpty)
        ? 'None'
        : item.packagingUnit;

    // Ensure the selected value is in the dropdown options
    if (selectedPackagingUnit != null && selectedPackagingUnit != 'None' && !packagingUnits.contains(selectedPackagingUnit)) {
      packagingUnits.add(selectedPackagingUnit!);
    }

    await showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (itemDialogContext) => StatefulBuilder(
        builder: (itemDialogContext, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: AppTheme.primaryAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Edit Item', style: AppTheme.heading3),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Item Name',
                    hint: 'Enter item name',
                    controller: itemNameController,
                    prefixIcon: Icons.inventory_2_outlined,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Item name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Item Type Toggle
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Item Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('Product'),
                                value: false,
                                groupValue: isService,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      isService = value;
                                      selectedPricingType = null;
                                      // Clear service-related fields when switching to product
                                      if (!value) {
                                        selectedPackagingUnit = 'None';
                                      }
                                    });
                                  }
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('Service'),
                                value: true,
                                groupValue: isService,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      isService = value;
                                      selectedPricingType = null;
                                      // Clear product-related fields when switching to service
                                      if (value) {
                                        selectedPackagingUnit = 'None';
                                      }
                                    });
                                  }
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Base Unit Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Base Unit',
                        
                        style: AppTheme.labelText,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedBaseUnit,
                          decoration: InputDecoration(
                            hintText: 'Select base unit',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.normal,
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.straighten_outlined,
                                color: AppTheme.primaryAccent,
                                size: 20,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          items: getBaseUnits(isService).map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedBaseUnit = value;
                              // Auto-set pricing type for services based on base unit
                              if (isService) {
                                selectedPricingType = _getDefaultPricingType(value, isService);
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Base unit is required';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Service pricing type removed - services are automatically fixed

                  // Packaging Unit Dropdown - only show when Product is selected
                  if (!isService) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Packaging Unit (Optional)',
                        style: AppTheme.labelText,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedPackagingUnit,
                          decoration: InputDecoration(
                            hintText: 'Select packaging unit',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.normal,
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: AppTheme.primaryAccent,
                                size: 20,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          items: packagingUnits.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPackagingUnit = value;
                              // Clear sqft per unit if no packaging unit selected
                              if (value == null) {
                                sqftController.clear();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sqft per Unit - only show when packaging unit is not 'None'
                  if (selectedPackagingUnit != null && selectedPackagingUnit != 'None') ...[
                    AppTextField(
                      label: selectedBaseUnit != null && selectedPackagingUnit != null
                          ? '$selectedBaseUnit per $selectedPackagingUnit'
                          : 'Sqft per Unit',
                      hint: selectedBaseUnit != null && selectedPackagingUnit != null
                          ? 'Ex: 0.33 (${selectedBaseUnit?.toLowerCase()} per ${selectedPackagingUnit?.toLowerCase()})'
                          : 'Ex: 0.33',
                      controller: sqftController,
                      prefixIcon: Icons.calculate_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Sqft per unit is required';
                        final num = double.tryParse(value!);
                        if (num == null || num <= 0) return 'Enter valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancel',
                          type: AppButtonType.outlined,
                          onPressed: () => Navigator.pop(itemDialogContext),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Update',
                          icon: Icons.check_rounded,
                          isLoading: isLoading,
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() => isLoading = true);
                              try {
                                final token = _getToken();
                                final packagingUnitToSend = selectedPackagingUnit == 'None' ? null : selectedPackagingUnit;
                                final sqftValue = (selectedPackagingUnit == null || selectedPackagingUnit == 'None')
                                    ? 0.0 // Default value when no packaging unit
                                    : double.parse(sqftController.text.trim());

                                await context.read<CategoryCubit>().updateItem(
                                  category.id,
                                  item.id,
                                  itemNameController.text.trim(),
                                  selectedBaseUnit!,
                                  packagingUnitToSend,
                                  sqftValue,
                                  isService,
                                  selectedPricingType,
                                  token: token,
                                );
                                Navigator.pop(itemDialogContext);

                                // Refresh dashboard data for real-time updates
                                if (token != null) {
                                  context.read<DashboardCubit>().refreshData(token: token);
                                }

                                _showSuccessSnackBar('Item updated successfully!');
                              } catch (e) {
                                _showErrorSnackBar('Failed to update item: ${e.toString()}');
                              }
                              setState(() => isLoading = false);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteItemDialog(ItemModel item, CategoryModel category) async {
    final result = await ConfirmDialog.show(
      context: context,
      title: 'Delete Item',
      message: 'Are you sure you want to delete "${item.itemName}"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_rounded,
      isDanger: true,
    );

    if (result == true) {
      try {
        final token = _getToken();
        await context.read<CategoryCubit>().deleteItem(category.id, item.id, token: token);

        // Refresh dashboard data for real-time updates
        if (token != null) {
          context.read<DashboardCubit>().refreshData(token: token);
        }

        _showSuccessSnackBar('Item "${item.itemName}" deleted successfully!');
      } catch (e) {
        _showErrorSnackBar('Failed to delete item: ${e.toString()}');
      }
    }
  }

  // ═══════════════════════════════════════
  // ✅ SUCCESS & ❌ ERROR SNACKBARS
  // ═══════════════════════════════════════
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
