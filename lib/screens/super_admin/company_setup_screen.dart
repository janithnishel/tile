import 'package:flutter/material.dart';
import 'package:tilework/models/super_admin/category_model.dart';
import 'package:tilework/models/super_admin/company_model.dart';
import 'package:tilework/theme/theme.dart';
import 'package:tilework/widget/super_admin/app_button.dart';
import 'package:tilework/widget/super_admin/app_card.dart';
import 'package:tilework/widget/super_admin/app_text_field.dart';
import 'package:tilework/widget/super_admin/dialogs/confirm_dialog.dart';
import 'package:tilework/widget/super_admin/dialogs/item_template_dialog.dart';
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
  // Categories list
  final List<CategoryModel> _categories = [
    CategoryModel(id: '1', name: 'LVT', companyId: '1'),
    CategoryModel(id: '2', name: 'Skirting', companyId: '1'),
    CategoryModel(id: '3', name: 'Labor', companyId: '1'),
    CategoryModel(id: '4', name: 'Ceramic Tiles', companyId: '1'),
  ];

  // Store item templates per category
  final Map<String, List<ItemTemplateModel>> _itemTemplates = {};

  @override
  Widget build(BuildContext context) {
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
                _buildCompanyInfoCard(),

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
                    onPressed: _showAddCategoryDialog, // 👈 Fixed!
                  ),
                ),

                const SizedBox(height: 16),

                // Categories Grid
                _categories.isEmpty
                    ? _buildEmptyCategoryState()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate responsive crossAxisCount based on available width
                          final availableWidth = constraints.maxWidth;
                          final cardMinWidth = 200.0; // Minimum card width
                          final crossAxisCount = (availableWidth / cardMinWidth)
                              .floor()
                              .clamp(1, 4);

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: crossAxisCount <= 2
                                      ? 1.8
                                      : 1.5,
                                ),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              return _buildCategoryCard(_categories[index]);
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ],
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
  Widget _buildCompanyInfoCard() {
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
              '${_categories.length} categories',
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
  // 📦 CATEGORY CARD
  // ═══════════════════════════════════════
  Widget _buildCategoryCard(CategoryModel category) {
    final itemCount = _itemTemplates[category.id]?.length ?? 0;

    return AppCard(
      onTap: () => _openItemTemplateDialog(category),
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
              // Item count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: itemCount > 0
                      ? AppTheme.success.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$itemCount items',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: itemCount > 0 ? AppTheme.success : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Edit button
              _buildCardAction(
                icon: Icons.edit_outlined,
                color: AppTheme.primaryAccent,
                onTap: () => _showEditCategoryDialog(category),
              ),
              // Delete button
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

    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
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
                // Header
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

                // Input
                AppTextField(
                  label: 'Category Name',
                  hint: 'Enter category name (e.g., LVT, Ceramic)',
                  controller: nameController,
                  prefixIcon: Icons.category_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category name is required';
                    }
                    // Check if category already exists
                    if (_categories.any(
                      (c) => c.name.toLowerCase() == value.toLowerCase(),
                    )) {
                      return 'Category already exists';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Actions - Responsive layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final useVerticalLayout =
                        maxWidth < 350; // Breakpoint for vertical layout

                    if (useVerticalLayout) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppButton(
                            text: 'Add Category',
                            icon: Icons.add_rounded,
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.pop(
                                  context,
                                  nameController.text.trim(),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            text: 'Cancel',
                            type: AppButtonType.outlined,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Cancel',
                              type: AppButtonType.outlined,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              text: 'Add Category',
                              icon: Icons.add_rounded,
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  Navigator.pop(
                                    context,
                                    nameController.text.trim(),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _categories.add(
          CategoryModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: result,
            companyId: widget.company.id,
          ),
        );
      });
      _showSuccessSnackBar('Category "$result" added successfully!');
    }
  }

  // ═══════════════════════════════════════
  // ✏️ EDIT CATEGORY DIALOG
  // ═══════════════════════════════════════
  Future<void> _showEditCategoryDialog(CategoryModel category) async {
    final nameController = TextEditingController(text: category.name);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
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
                // Header
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

                // Input
                AppTextField(
                  label: 'Category Name',
                  hint: 'Enter category name',
                  controller: nameController,
                  prefixIcon: Icons.category_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category name is required';
                    }
                    // Check if category already exists (except current)
                    if (_categories.any(
                      (c) =>
                          c.id != category.id &&
                          c.name.toLowerCase() == value.toLowerCase(),
                    )) {
                      return 'Category already exists';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Actions - Responsive layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final useVerticalLayout =
                        maxWidth < 350; // Breakpoint for vertical layout

                    if (useVerticalLayout) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppButton(
                            text: 'Update',
                            icon: Icons.check_rounded,
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.pop(
                                  context,
                                  nameController.text.trim(),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            text: 'Cancel',
                            type: AppButtonType.outlined,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Cancel',
                              type: AppButtonType.outlined,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              text: 'Update',
                              icon: Icons.check_rounded,
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  Navigator.pop(
                                    context,
                                    nameController.text.trim(),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        final index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = CategoryModel(
            id: category.id,
            name: result,
            companyId: category.companyId,
          );
        }
      });
      _showSuccessSnackBar('Category updated successfully!');
    }
  }

  // ═══════════════════════════════════════
  // 🗑️ DELETE CATEGORY DIALOG
  // ═══════════════════════════════════════
  Future<void> _showDeleteCategoryDialog(CategoryModel category) async {
    final result = await ConfirmDialog.show(
      context: context,
      title: 'Delete Category',
      message:
          'Are you sure you want to delete "${category.name}"?\n\nAll item templates in this category will also be deleted.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_forever_rounded,
      isDanger: true,
    );

    if (result == true) {
      setState(() {
        _categories.removeWhere((c) => c.id == category.id);
        _itemTemplates.remove(category.id);
      });
      _showSuccessSnackBar('Category "${category.name}" deleted!');
    }
  }

  // ═══════════════════════════════════════
  // 📦 ITEM TEMPLATE DIALOG
  // ═══════════════════════════════════════
  Future<void> _openItemTemplateDialog(CategoryModel category) async {
    final currentItems = _itemTemplates[category.id] ?? [];

    final result = await ItemTemplateDialog.show(
      context,
      category,
      currentItems,
    );

    if (result != null) {
      setState(() {
        _itemTemplates[category.id] = result;
      });
    }
  }

  // ═══════════════════════════════════════
  // ✅ SUCCESS SNACKBAR
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
}
