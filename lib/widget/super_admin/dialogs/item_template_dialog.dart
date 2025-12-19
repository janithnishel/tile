// lib/widgets/dialogs/item_template_dialog.dart

import 'package:flutter/material.dart';
import 'package:tilework/models/category_model.dart';
import 'package:tilework/theme/theme.dart';
import 'package:tilework/widget/super_admin/app_button.dart';
import 'package:tilework/widget/super_admin/app_card.dart';
import 'package:tilework/widget/super_admin/app_text_field.dart';

class ItemTemplateDialog extends StatefulWidget {
  final CategoryModel category;
  final List<ItemTemplateModel> items;
  final Map<String, dynamic>? itemConfigs;

  const ItemTemplateDialog({
    Key? key,
    required this.category,
    required this.items,
    this.itemConfigs,
  }) : super(key: key);

  static Future<List<ItemTemplateModel>?> show(
    BuildContext context,
    CategoryModel category,
    List<ItemTemplateModel> items, {
    Map<String, dynamic>? itemConfigs,
  }) {
    return showDialog<List<ItemTemplateModel>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ItemTemplateDialog(
        category: category,
        items: items,
        itemConfigs: itemConfigs,
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
  final _sqftPerUnitController = TextEditingController();

  // Dynamic unit options from configs - include all possible existing units
  List<String> get _serviceUnits {
    // For services, include 'fixed' plus any existing units to prevent dropdown errors
    final configUnits = widget.itemConfigs?['unit_configs']?['service_units']?.cast<String>() ?? ['sqft', 'ft',];
    // Always include 'fixed' as the first option for new services
    return ['fixed', ...configUnits.where((unit) => unit != 'fixed')];
  }
  List<String> get _productUnits => widget.itemConfigs?['unit_configs']?['product_units']?.cast<String>() ?? ['sqft', 'ft', 'pcs', 'kg', 'm'];

  // Packaging unit options (keeping static for now)
  final List<String> _packagingUnits = ['Box', 'Roll', 'Sheet', 'Pcs'];
  String? _selectedPackagingUnit;

  // Base unit options - dynamic based on item type
  List<String> get _baseUnits => _isService ? _serviceUnits : _productUnits;
  String? _selectedBaseUnit;

  // Item type toggle
  bool _isService = false;
  ServicePricingType? _selectedPricingType;

  // Get default pricing type based on base unit selection
  ServicePricingType? _getDefaultPricingType(String? baseUnit) {
    if (!_isService || baseUnit == null) return null;

    // Service pricing logic
    if (['sqft', 'ft'].contains(baseUnit)) {
      return ServicePricingType.variable; // Area-based services default to variable pricing
    } else if (['Job', 'Visit'].contains(baseUnit)) {
      return ServicePricingType.fixed; // One-time services default to fixed pricing
    }

    return ServicePricingType.variable; // Default fallback
  }

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void dispose() {
    _itemNameController.dispose();
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
                                RadioGroup<bool>(
                                  groupValue: _isService,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _isService = value;
                                        if (!value) _selectedPricingType = null;
                                        // Clear packaging fields when switching to service
                                        if (value) {
                                          _selectedPackagingUnit = null;
                                          _sqftPerUnitController.clear();
                                        }
                                      });
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: const Text('Product'),
                                          leading: Radio<bool>(
                                            value: false,
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          dense: true,
                                        ),
                                      ),
                                      Expanded(
                                        child: ListTile(
                                          title: const Text('Service'),
                                          leading: Radio<bool>(
                                            value: true,
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          dense: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                            initialValue: _selectedBaseUnit,
                            decoration: InputDecoration(
                              labelText: 'Base Unit',
                              hintText: 'Select base unit',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            items: _baseUnits.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBaseUnit = value;
                                // Auto-set pricing type for services based on base unit
                                if (_isService) {
                                  _selectedPricingType = _getDefaultPricingType(value);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // Conditional fields based on item type
                          if (!_isService) ...[
                            // Product fields
                            DropdownButtonFormField<String>(
                              initialValue: _selectedPackagingUnit,
                              decoration: InputDecoration(
                                labelText: 'Packaging Unit',
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

                            // Base Unit per Box - required when packaging unit is selected
                            AppTextField(
                              label: 'Base Unit per Box',
                              hint: 'Ex: 3.5 (meters per box)',
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
                          // First row: Item Name and Item Type
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: AppTextField(
                                  label: 'Item Name',
                                  hint: 'Ex: Skirting - 4 Inch',
                                  controller: _itemNameController,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Item Type Toggle
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 12, top: 8),
                                        child: Text(
                                          'Item Type',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      RadioGroup<bool>(
                                        groupValue: _isService,
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _isService = value;
                                              if (!value) _selectedPricingType = null;
                                              // Clear packaging fields when switching to service
                                              if (value) {
                                                _selectedPackagingUnit = null;
                                                _sqftPerUnitController.clear();
                                              }
                                            });
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: ListTile(
                                                title: const Text('Product', style: TextStyle(fontSize: 12)),
                                                leading: Radio<bool>(
                                                  value: false,
                                                ),
                                                contentPadding: EdgeInsets.zero,
                                                dense: true,
                                              ),
                                            ),
                                            Expanded(
                                              child: ListTile(
                                                title: const Text('Service', style: TextStyle(fontSize: 12)),
                                                leading: Radio<bool>(
                                                  value: true,
                                                ),
                                                contentPadding: EdgeInsets.zero,
                                                dense: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Second row: Base Unit and conditional fields
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedBaseUnit,
                                  decoration: InputDecoration(
                                    labelText: 'Base Unit',
                                    hintText: 'Select base unit',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  ),
                                  items: _baseUnits.map((unit) {
                                    return DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedBaseUnit = value;
                                      // Auto-set pricing type for services based on base unit
                                      if (_isService) {
                                        _selectedPricingType = _getDefaultPricingType(value);
                                      }
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Conditional fields based on item type
                              if (!_isService) ...[
                                // Product fields
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedPackagingUnit,
                                    decoration: InputDecoration(
                                      labelText: 'Packaging Unit',
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
                                Expanded(
                                  flex: 2,
                                  child: AppTextField(
                                    label: 'Base Unit per Box',
                                    hint: 'Ex: 3.5 (meters per box)',
                                    controller: _sqftPerUnitController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ] else ...[
                                // Service fields
                                Expanded(
                                  flex: 4,
                                  child: DropdownButtonFormField<ServicePricingType>(
                                    initialValue: _selectedPricingType,
                                    decoration: InputDecoration(
                                      labelText: 'Service Pricing Type',
                                      hintText: 'Select pricing type',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: ServicePricingType.fixed,
                                        child: Text('Fixed: Total amount regardless of quantity'),
                                      ),
                                      DropdownMenuItem(
                                        value: ServicePricingType.variable,
                                        child: Text('Variable: Price per unit of Base Unit'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPricingType = value;
                                      });
                                    },
                                  ),
                                ),
                              ],

                              const SizedBox(width: 12),
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
                                          child: Row(
                                            children: [
                                              Text(
                                                item.itemName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: item.isService ? Colors.blue.shade100 : Colors.green.shade100,
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                                child: Text(
                                                  item.isService ? 'SERVICE' : 'PRODUCT',
                                                  style: TextStyle(
                                                    color: item.isService ? Colors.blue.shade800 : Colors.green.shade800,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 8,
                                                  ),
                                                ),
                                              ),
                                            ],
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
                                          Row(
                                            children: [
                                              Text(
                                                item.itemName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: item.isService ? Colors.blue.shade100 : Colors.green.shade100,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item.isService ? 'SERVICE' : 'PRODUCT',
                                                  style: TextStyle(
                                                    color: item.isService ? Colors.blue.shade800 : Colors.green.shade800,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'Base Unit: ${item.baseUnit}',
                                            style: AppTheme.bodyMedium,
                                          ),
                                          if (item.isService && item.pricingType != null)
                                            Text(
                                              'Pricing: ${item.pricingType == ServicePricingType.fixed ? 'Fixed' : 'Variable'}',
                                              style: AppTheme.bodyMedium.copyWith(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Sqft per unit or service info
                                    if (!item.isService)
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
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item.pricingType == ServicePricingType.fixed ? 'FIXED PRICE' : 'PER UNIT',
                                          style: TextStyle(
                                            color: Colors.blue.shade800,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
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
    if (_itemNameController.text.isEmpty || _selectedBaseUnit == null) {
      return;
    }

    // For products, if packaging unit is selected, sqft per unit is required
    if (!_isService && _selectedPackagingUnit != null && _sqftPerUnitController.text.isEmpty) {
      return;
    }

    setState(() {
      final newItem = ItemTemplateModel(
        id: _editingIndex != null
            ? _items[_editingIndex!].id
            : DateTime.now().toString(),
        itemName: _itemNameController.text.trim(),
        baseUnit: _selectedBaseUnit!,
        packagingUnit: !_isService ? _selectedPackagingUnit : null,
        sqftPerUnit: !_isService ? (double.tryParse(_sqftPerUnitController.text) ?? 0) : 0,
        categoryId: widget.category.id,
        isService: _isService,
        pricingType: _isService ? ServicePricingType.fixed : null, // Always fixed for services
      );

      if (_editingIndex != null) {
        _items[_editingIndex!] = newItem;
      } else {
        _items.add(newItem);
      }
    });

    // Clear form and reset editing index
    _itemNameController.clear();
    _sqftPerUnitController.clear();
    setState(() {
      _selectedBaseUnit = null;
      _selectedPackagingUnit = null;
      _isService = false;
      _selectedPricingType = null;
      _editingIndex = null;
    });
  }

  void _editItem(int index) {
    setState(() {
      _editingIndex = index;
      final item = _items[index];
      _itemNameController.text = item.itemName;
      _selectedBaseUnit = item.baseUnit;
      _selectedPackagingUnit = item.packagingUnit;
      _sqftPerUnitController.text = item.sqftPerUnit.toString();
      _isService = item.isService;
      _selectedPricingType = item.pricingType;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }
}
