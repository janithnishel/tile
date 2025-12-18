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
  int? _editingIndex; // To keep track of the item being edited

  // Controllers for new item
  final _itemNameController = TextEditingController();
  final _baseUnitController = TextEditingController();
  final _sqftPerUnitController = TextEditingController();

  // Packaging unit options
  final List<String> _packagingUnits = ['Box', 'Roll', 'Sheet', 'Pcs'];
  String? _selectedPackagingUnit;

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
                          // Packaging Unit Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedPackagingUnit,
                            decoration: InputDecoration(
                              labelText: 'Packaging Unit (Optional)',
                              hintText: 'Select packaging unit',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            items: _packagingUnits.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPackagingUnit = value;
                                // Clear sqft per unit if no packaging unit selected
                                if (value == null) {
                                  _sqftPerUnitController.clear();
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          // Sqft per Unit - only show when packaging unit is selected
                          if (_selectedPackagingUnit != null) ...[
                            AppTextField(
                              label: 'Sqft per Unit',
                              hint: 'Ex: 0.33 (total sqft per ${_selectedPackagingUnit?.toLowerCase()})',
                              controller: _sqftPerUnitController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: AppButton(
                                  text: _editingIndex != null ? 'Save' : 'Add',
                                  icon: _editingIndex != null
                                      ? Icons.save_rounded
                                      : Icons.add_rounded,
                                  onPressed: _saveItem,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // Horizontal layout for larger screens
                      return Column(
                        children: [
                          Row(
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
                                child: DropdownButtonFormField<String>(
                                  value: _selectedPackagingUnit,
                                  decoration: InputDecoration(
                                    labelText: 'Packaging Unit (Optional)',
                                    hintText: 'Select unit',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  ),
                                  items: _packagingUnits.map((unit) {
                                    return DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPackagingUnit = value;
                                      // Clear sqft per unit if no packaging unit selected
                                      if (value == null) {
                                        _sqftPerUnitController.clear();
                                      }
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (_selectedPackagingUnit != null) ...[
                                Expanded(
                                  flex: 2,
                                  child: AppTextField(
                                    label: 'Sqft per Unit',
                                    hint: 'Ex: 0.33 (per ${_selectedPackagingUnit?.toLowerCase()})',
                                    controller: _sqftPerUnitController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Padding(
                                padding: const EdgeInsets.only(top: 28),
                                child: AppButton(
                                  text: _editingIndex != null ? 'Save' : 'Add',
                                  icon: _editingIndex != null
                                      ? Icons.save_rounded
                                      : Icons.add_rounded,
                                  onPressed: _saveItem,
                                ),
                              ),
                            ],
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
                                        // Edit button
                                        IconButton(
                                          onPressed: () => _editItem(index),
                                          icon:  Icon(
                                            Icons.edit_outlined,
                                            color: AppTheme.primary,
                                            size: 20,
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

                                    // Edit button
                                    IconButton(
                                      onPressed: () => _editItem(index),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: AppTheme.primary,
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

  void _saveItem() {
    // Validate required fields
    if (_itemNameController.text.isEmpty || _baseUnitController.text.isEmpty) {
      return;
    }

    // If packaging unit is selected, sqft per unit is required
    if (_selectedPackagingUnit != null && _sqftPerUnitController.text.isEmpty) {
      return;
    }

    // If no packaging unit selected, sqft per unit is still required for base calculation
    if (_selectedPackagingUnit == null && _sqftPerUnitController.text.isEmpty) {
      return;
    }

    setState(() {
      final newItem = ItemTemplateModel(
        id: _editingIndex != null
            ? _items[_editingIndex!].id
            : DateTime.now().toString(),
        itemName: _itemNameController.text.trim(),
        baseUnit: _baseUnitController.text.trim(),
        packagingUnit: _selectedPackagingUnit,
        sqftPerUnit: double.tryParse(_sqftPerUnitController.text) ?? 0,
        categoryId: widget.category.id,
      );

      if (_editingIndex != null) {
        _items[_editingIndex!] = newItem;
      } else {
        _items.add(newItem);
      }
    });

    // Clear form and reset editing index
    _itemNameController.clear();
    _baseUnitController.clear();
    _sqftPerUnitController.clear();
    setState(() {
      _selectedPackagingUnit = null;
      _editingIndex = null;
    });
  }

  void _editItem(int index) {
    setState(() {
      _editingIndex = index;
      final item = _items[index];
      _itemNameController.text = item.itemName;
      _baseUnitController.text = item.baseUnit;
      _selectedPackagingUnit = item.packagingUnit;
      _sqftPerUnitController.text = item.sqftPerUnit.toString();
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }
}
