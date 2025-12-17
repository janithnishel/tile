import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/super_admin/category/category_cubit.dart';
import 'package:tilework/models/category_model.dart';
import 'package:tilework/models/purchase_order_screen/supplier.dart';

class AddSupplierDialog extends StatefulWidget {
  final Function(Supplier) onAdd;

  const AddSupplierDialog({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends State<AddSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  List<String> _selectedCategories = [];

  List<String> _availableCategories = [];
  bool _isLoadingCategories = true;

  late AuthCubit _authCubit;
  late CategoryCubit _categoryCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load categories safely when context is available
    if (_isLoadingCategories) {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final categoryCubit = context.read<CategoryCubit>();
        await categoryCubit.loadCategories(token: authState.token);

        // 🚨 Check if widget is still mounted before using context
        if (!mounted) return;

        // Update categories list
        setState(() {
          _availableCategories = categoryCubit.state.categories.map((cat) => cat.name).toList();
          _isLoadingCategories = false;
          // Set default category if available and not already selected
          if (_availableCategories.isNotEmpty && _selectedCategories.isEmpty) {
            _selectedCategories = [_availableCategories.first];
          }
        });
      }
    } catch (e) {
      // 🚨 Check if widget is still mounted before using context
      if (!mounted) return;

      // On error, use default categories
      setState(() {
        _availableCategories = [
          'Hardware',
          'Cement & Sand',
          'Tiles & Flooring',
          'Steel & Metal',
          'Paints',
          'Electrical',
          'Plumbing',
          'Tools & Equipment',
        ];
        _isLoadingCategories = false;
        // Set default category if available and not already selected
        if (_availableCategories.isNotEmpty && _selectedCategories.isEmpty) {
          _selectedCategories = [_availableCategories.first];
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _generateSupplierId(List<Supplier> existingSuppliers) {
    if (existingSuppliers.isEmpty) return 'SUP001';

    final ids = existingSuppliers.map((s) => s.id).toList();
    ids.sort();

    final lastId = ids.last;
    final number = int.tryParse(lastId.substring(3)) ?? 0;
    final nextNumber = number + 1;

    return 'SUP${nextNumber.toString().padLeft(3, '0')}';
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // For now, we'll pass an empty list and generate ID in the parent
      // In a real app, this would be handled by a service/repository
      final newSupplier = Supplier(
        id: '', // Will be set by parent
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        categories: _selectedCategories,
      );

      widget.onAdd(newSupplier);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add New Supplier'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildContent()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade600, Colors.teal.shade800],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.business,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Add New Supplier',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Supplier Name *',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Supplier name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Field
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Phone number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Address Field
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Categories Multi-Select
            if (_isLoadingCategories)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading categories...'),
                  ],
                ),
              )
            else
              FormField<List<String>>(
                initialValue: _selectedCategories,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select at least one category';
                  }
                  return null;
                },
                builder: (FormFieldState<List<String>> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categories *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableCategories.map((category) {
                          final isSelected = _selectedCategories.contains(category);
                          return FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCategories.add(category);
                                } else {
                                  _selectedCategories.remove(category);
                                }
                              });
                              state.didChange(_selectedCategories);
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: Colors.teal.shade100,
                            checkmarkColor: Colors.teal,
                          );
                        }).toList(),
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.add),
            label: const Text('Add Supplier'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
