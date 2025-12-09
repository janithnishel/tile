// lib/widgets/dialogs/item_template_dialog.dart

import 'package:flutter/material.dart';
import 'package:tilework/models/super_admin/category_model.dart';
import 'package:tilework/theme/theme.dart';
import 'package:tilework/widget/super_admin/app_button.dart';
import 'package:tilework/widget/super_admin/app_card.dart';
import 'package:tilework/widget/super_admin/app_text_field.dart';

class ItemTemplateDialog extends StatefulWidget {
  final CategoryModel category;
  final List<ItemTemplateModel> items;

  const ItemTemplateDialog({
    Key? key,
    required this.category,
    required this.items,
  }) : super(key: key);

  static Future<List<ItemTemplateModel>?> show(
    BuildContext context,
    CategoryModel category,
    List<ItemTemplateModel> items,
  ) {
    return showDialog<List<ItemTemplateModel>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ItemTemplateDialog(
        category: category,
        items: items,
      ),
    );
  }

  @override
  State<ItemTemplateDialog> createState() => _ItemTemplateDialogState();
}

class _ItemTemplateDialogState extends State<ItemTemplateDialog> {
  late List<ItemTemplateModel> _items;
  final _formKey = GlobalKey<FormState>();

  // Controllers for new item
  final _itemNameController = TextEditingController();
  final _baseUnitController = TextEditingController();
  final _sqftPerUnitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _baseUnitController.dispose();
    _sqftPerUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Column(
          children: [
            // ═══════════════════════════════════════
            // 🔝 HEADER
            // ═══════════════════════════════════════
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusLg),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.category.name} - Item Templates',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Manage item templates for this category',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // 📝 ADD NEW ITEM FORM
            // ═══════════════════════════════════════
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(color: AppTheme.border),
                ),
              ),
              child: Form(
                key: _formKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final useVerticalLayout = maxWidth < 600; // Breakpoint for responsive layout

                    if (useVerticalLayout) {
                      // Vertical layout for smaller screens
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            label: 'Item Name',
                            hint: 'Ex: Skirting - 4 Inch',
                            controller: _itemNameController,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'Base Unit',
                            hint: 'Ex: Linear Meter',
                            controller: _baseUnitController,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  label: 'Sqft per Unit',
                                  hint: 'Ex: 0.33',
                                  controller: _sqftPerUnitController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: AppButton(
                                  text: 'Add',
                                  icon: Icons.add_rounded,
                                  onPressed: _addItem,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // Horizontal layout for larger screens
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppTextField(
                              label: 'Item Name',
                              hint: 'Ex: Skirting - 4 Inch',
                              controller: _itemNameController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: AppTextField(
                              label: 'Base Unit',
                              hint: 'Ex: Linear Meter',
                              controller: _baseUnitController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: AppTextField(
                              label: 'Sqft per Unit',
                              hint: 'Ex: 0.33',
                              controller: _sqftPerUnitController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(top: 28),
                            child: AppButton(
                              text: 'Add',
                              icon: Icons.add_rounded,
                              onPressed: _addItem,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),

            // ═══════════════════════════════════════
            // 📋 ITEMS LIST
            // ═══════════════════════════════════════
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items added yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return AppCard(
                          padding: const EdgeInsets.all(12),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final maxWidth = constraints.maxWidth;
                              final useCompactLayout = maxWidth < 500; // Breakpoint for compact layout

                              if (useCompactLayout) {
                                // Compact vertical layout for very small screens
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Icon
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.success.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.inventory_rounded,
                                            color: AppTheme.success,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Name
                                        Expanded(
                                          child: Text(
                                            item.itemName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        // Delete button
                                        IconButton(
                                          onPressed: () => _deleteItem(index),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: AppTheme.error,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Base unit and sqft info
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Base Unit: ${item.baseUnit}',
                                            style: AppTheme.bodyMedium.copyWith(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                        // Sqft per unit badge (smaller)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryAccent.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${item.sqftPerUnit} sqft/unit',
                                            style: TextStyle(
                                              color: AppTheme.primaryAccent,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                // Normal horizontal layout for larger screens
                                return Row(
                                  children: [
                                    // Icon
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.success.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.inventory_rounded,
                                        color: AppTheme.success,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Name
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.itemName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            'Base Unit: ${item.baseUnit}',
                                            style: AppTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Sqft per unit
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${item.sqftPerUnit} sqft/unit',
                                        style: TextStyle(
                                          color: AppTheme.primaryAccent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Delete button
                                    IconButton(
                                      onPressed: () => _deleteItem(index),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppTheme.error,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),

            // ═══════════════════════════════════════
            // 🔘 ACTIONS
            // ═══════════════════════════════════════
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppTheme.radiusLg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Cancel',
                    type: AppButtonType.outlined,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    text: 'Save Changes',
                    icon: Icons.check_rounded,
                    onPressed: () => Navigator.pop(context, _items),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem() {
    if (_itemNameController.text.isEmpty ||
        _baseUnitController.text.isEmpty ||
        _sqftPerUnitController.text.isEmpty) {
      return;
    }

    setState(() {
      _items.add(ItemTemplateModel(
        id: DateTime.now().toString(),
        itemName: _itemNameController.text.trim(),
        baseUnit: _baseUnitController.text.trim(),
        sqftPerUnit: double.tryParse(_sqftPerUnitController.text) ?? 0,
        categoryId: widget.category.id,
      ));
    });

    _itemNameController.clear();
    _baseUnitController.clear();
    _sqftPerUnitController.clear();
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }
}
