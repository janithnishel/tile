// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tilework/cubits/auth/auth_cubit.dart';
// import 'package:tilework/cubits/auth/auth_state.dart';
// import 'package:tilework/cubits/super_admin/category/category_cubit.dart';
// import 'package:tilework/models/category_model.dart';
// import 'package:tilework/models/purchase_order/supplier.dart';

// class EditSupplierDialog extends StatefulWidget {
//   final Supplier supplier;
//   final Function(Supplier) onEdit;

//   const EditSupplierDialog({
//     Key? key,
//     required this.supplier,
//     required this.onEdit,
//   }) : super(key: key);

//   @override
//   State<EditSupplierDialog> createState() => _EditSupplierDialogState();
// }

// class _EditSupplierDialogState extends State<EditSupplierDialog> {
//   final _formKey = GlobalKey<FormState>();
//   late final TextEditingController _nameController;
//   late final TextEditingController _phoneController;
//   late final TextEditingController _emailController;
//   late final TextEditingController _addressController;
//   late List<String> _selectedCategories;

//   List<String> _categories = [];
//   bool _isLoadingCategories = true;

//   late AuthCubit _authCubit;
//   late CategoryCubit _categoryCubit;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize controllers with existing supplier data
//     _nameController = TextEditingController(text: widget.supplier.name);
//     _phoneController = TextEditingController(text: widget.supplier.phone);
//     _emailController = TextEditingController(text: widget.supplier.email);
//     _addressController = TextEditingController(text: widget.supplier.address);
//     _selectedCategories = List.from(widget.supplier.categories);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Load categories safely when context is available
//     if (_isLoadingCategories) {
//       _loadCategories();
//     }
//   }

//   Future<void> _loadCategories() async {
//     // Default categories that are always available
//     final defaultCategories = [
//       'Hardware',
//       'Cement & Sand',
//       'Tiles & Flooring',
//       'Steel & Metal',
//       'Paints',
//       'Electrical',
//       'Plumbing',
//       'Tools & Equipment',
//     ];

//     try {
//       final authState = context.read<AuthCubit>().state;
//       if (authState is AuthAuthenticated) {
//         final categoryCubit = context.read<CategoryCubit>();
//         await categoryCubit.loadCategories(token: authState.token);

//         if (!mounted) return;

//         // Combine API categories with default categories, and ensure existing supplier categories are included
//         final apiCategories = categoryCubit.state.categories
//             .map((cat) => cat.name)
//             .toList();

//         final allCategories = {...apiCategories, ...defaultCategories, ...widget.supplier.categories}.toList();

//         setState(() {
//           _categories = allCategories;
//           _isLoadingCategories = false;
//         });
//       } else {
//         // If not authenticated, use default categories plus existing supplier categories
//         final allCategories = {...defaultCategories, ...widget.supplier.categories}.toList();
//         setState(() {
//           _categories = allCategories;
//           _isLoadingCategories = false;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;

//       // On error, use default categories plus existing supplier categories
//       final allCategories = {...defaultCategories, ...widget.supplier.categories}.toList();
//       setState(() {
//         _categories = allCategories;
//         _isLoadingCategories = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     if (_formKey.currentState!.validate()) {
//       // Create updated supplier with existing ID
//       final updatedSupplier = Supplier(
//         id: widget.supplier.id,
//         name: _nameController.text.trim(),
//         phone: _phoneController.text.trim(),
//         email: _emailController.text.trim(),
//         address: _addressController.text.trim(),
//         categories: _selectedCategories,
//       );

//       widget.onEdit(updatedSupplier);
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Container(
//         width: 500,
//         constraints: const BoxConstraints(maxHeight: 600),
//         child: Column(
//           children: [
//             _buildHeader(),
//             Expanded(child: _buildContent()),
//             _buildFooter(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue.shade600, Colors.blue.shade800],
//         ),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.edit,
//             color: Colors.white,
//             size: 28,
//           ),
//           const SizedBox(width: 12),
//           const Text(
//             'Edit Supplier',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const Spacer(),
//           IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(Icons.close, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Name Field
//             TextFormField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Supplier Name *',
//                 prefixIcon: const Icon(Icons.business),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               validator: (value) {
//                 if (value == null || value.trim().isEmpty) {
//                   return 'Supplier name is required';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),

//             // Phone Field
//             TextFormField(
//               controller: _phoneController,
//               decoration: InputDecoration(
//                 labelText: 'Phone Number *',
//                 prefixIcon: const Icon(Icons.phone),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               keyboardType: TextInputType.phone,
//               validator: (value) {
//                 if (value == null || value.trim().isEmpty) {
//                   return 'Phone number is required';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),

//             // Email Field
//             TextFormField(
//               controller: _emailController,
//               decoration: InputDecoration(
//                 labelText: 'Email Address',
//                 prefixIcon: const Icon(Icons.email),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 16),

//             // Address Field
//             TextFormField(
//               controller: _addressController,
//               decoration: InputDecoration(
//                 labelText: 'Address',
//                 prefixIcon: const Icon(Icons.location_on),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               maxLines: 2,
//             ),
//             const SizedBox(height: 16),

//             // Categories Multi-Select
//             if (_isLoadingCategories)
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 child: const Row(
//                   children: [
//                     SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                     SizedBox(width: 12),
//                     Text('Loading categories...'),
//                   ],
//                 ),
//               )
//             else
//               FormField<List<String>>(
//                 initialValue: _selectedCategories,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select at least one category';
//                   }
//                   return null;
//                 },
//                 builder: (FormFieldState<List<String>> state) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Categories *',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: _categories.map((category) {
//                           final isSelected = _selectedCategories.contains(category);
//                           return FilterChip(
//                             label: Text(category),
//                             selected: isSelected,
//                             onSelected: (selected) {
//                               setState(() {
//                                 if (selected) {
//                                   _selectedCategories.add(category);
//                                 } else {
//                                   _selectedCategories.remove(category);
//                                 }
//                               });
//                               state.didChange(_selectedCategories);
//                             },
//                             backgroundColor: Colors.grey.shade100,
//                             selectedColor: Colors.blue.shade100,
//                             checkmarkColor: Colors.blue,
//                           );
//                         }).toList(),
//                       ),
//                       if (state.hasError)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8),
//                           child: Text(
//                             state.errorText!,
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.error,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                     ],
//                   );
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFooter() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           const SizedBox(width: 12),
//           ElevatedButton.icon(
//             onPressed: _submit,
//             icon: const Icon(Icons.save),
//             label: const Text('Update Supplier'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 24,
//                 vertical: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/super_admin/category/category_cubit.dart';
import 'package:tilework/models/purchase_order/supplier.dart';

class EditSupplierScreen extends StatefulWidget {
  final Supplier supplier;
  final Function(Supplier) onEdit;

  const EditSupplierScreen({
    Key? key,
    required this.supplier,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<EditSupplierScreen> createState() => _EditSupplierScreenState();
}

class _EditSupplierScreenState extends State<EditSupplierScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  late List<String> _selectedCategories;
  List<String> _availableCategories = [];
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;
  bool _hasChanges = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Focus nodes
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _addressFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    // Initialize with existing data
    _nameController = TextEditingController(text: widget.supplier.name);
    _phoneController = TextEditingController(text: widget.supplier.phone);
    _emailController = TextEditingController(text: widget.supplier.email);
    _addressController = TextEditingController(text: widget.supplier.address);
    _selectedCategories = List.from(widget.supplier.categories);

    // Listen for changes
    _nameController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _addressController.addListener(_checkForChanges);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    _animationController.forward();
  }

  void _checkForChanges() {
    final hasChanges = _nameController.text != widget.supplier.name ||
        _phoneController.text != widget.supplier.phone ||
        _emailController.text != widget.supplier.email ||
        _addressController.text != widget.supplier.address ||
        !_listEquals(_selectedCategories, widget.supplier.categories);

    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var item in a) {
      if (!b.contains(item)) return false;
    }
    return true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

        if (!mounted) return;

        // Use only API-loaded categories (same as AddSupplierScreen)
        final apiCategories = categoryCubit.state.categories
            .map((cat) => cat.name)
            .toList();

        setState(() {
          _availableCategories = apiCategories;
          _isLoadingCategories = false;
        });
      } else {
        // If not authenticated, show empty categories
        setState(() {
          _availableCategories = [];
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      // On error, show empty categories
      setState(() {
        _availableCategories = [];
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_amber, color: Colors.orange.shade700),
            ),
            const SizedBox(width: 12),
            const Text('Unsaved Changes'),
          ],
        ),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select at least one category'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final updatedSupplier = Supplier(
        id: widget.supplier.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        categories: _selectedCategories,
      );

      widget.onEdit(updatedSupplier);
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetToOriginal() {
    setState(() {
      _nameController.text = widget.supplier.name;
      _phoneController.text = widget.supplier.phone;
      _emailController.text = widget.supplier.email;
      _addressController.text = widget.supplier.address;
      _selectedCategories = List.from(widget.supplier.categories);
      _hasChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 12),
            Text('Reset to original values'),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildForm(),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.blue.shade700,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () async {
          if (await _onWillPop()) {
            Navigator.pop(context);
          }
        },
      ),
      actions: [
        // Reset Button
        if (_hasChanges)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
            onPressed: _resetToOriginal,
            tooltip: 'Reset to original',
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
                Colors.blue.shade800,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      // Supplier Avatar
                      Hero(
                        tag: 'supplier_${widget.supplier.id}',
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(_nameController.text),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.edit,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Edit Supplier',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _nameController.text.isEmpty
                                  ? 'Supplier Name'
                                  : _nameController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // ID Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.tag,
                                        size: 12,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.supplier.id,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Modified Badge
                                if (_hasChanges)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.edit_note,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Modified',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
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

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Original vs Current Comparison Card
            if (_hasChanges) _buildChangesComparisonCard(),

            if (_hasChanges) const SizedBox(height: 16),

            // Basic Information Card
            _buildCard(
              title: 'Basic Information',
              icon: Icons.info_outline,
              iconColor: Colors.blue,
              children: [
                _buildTextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  label: 'Supplier Name',
                  hint: 'Enter supplier name',
                  icon: Icons.business,
                  required: true,
                  originalValue: widget.supplier.name,
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => _phoneFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  label: 'Phone Number',
                  hint: 'Enter phone number',
                  icon: Icons.phone,
                  required: true,
                  originalValue: widget.supplier.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                  ],
                  onSubmitted: (_) => _emailFocus.requestFocus(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Contact Information Card
            _buildCard(
              title: 'Contact Information',
              icon: Icons.contact_mail_outlined,
              iconColor: Colors.green,
              children: [
                _buildTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  label: 'Email Address',
                  hint: 'supplier@example.com',
                  icon: Icons.email,
                  originalValue: widget.supplier.email,
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) => _addressFocus.requestFocus(),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  focusNode: _addressFocus,
                  label: 'Address',
                  hint: 'Enter supplier address',
                  icon: Icons.location_on,
                  originalValue: widget.supplier.address,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Categories Card
            _buildCard(
              title: 'Categories',
              icon: Icons.category_outlined,
              iconColor: Colors.purple,
              children: [
                if (_isLoadingCategories)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Loading categories...'),
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Select the categories this supplier provides *',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          // Show category change indicator
                          if (!_listEquals(_selectedCategories,
                              widget.supplier.categories))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.change_circle,
                                    size: 14,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Changed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _availableCategories.map((category) {
                          final isSelected =
                              _selectedCategories.contains(category);
                          final wasOriginal =
                              widget.supplier.categories.contains(category);
                          return _buildCategoryChip(
                              category, isSelected, wasOriginal);
                        }).toList(),
                      ),
                      if (_selectedCategories.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${_selectedCategories.length} categor${_selectedCategories.length > 1 ? 'ies' : 'y'} selected',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_selectedCategories.length !=
                                  widget.supplier.categories.length) ...[
                                const Spacer(),
                                Text(
                                  'was ${widget.supplier.categories.length}',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),

            // Bottom padding
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildChangesComparisonCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade200,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(Icons.compare_arrows, color: Colors.orange.shade800),
                const SizedBox(width: 10),
                Text(
                  'You have unsaved changes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _resetToOriginal,
                  icon: const Icon(Icons.undo, size: 16),
                  label: const Text('Undo All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange.shade800,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (_nameController.text != widget.supplier.name)
                  _buildChangeRow('Name', widget.supplier.name, _nameController.text),
                if (_phoneController.text != widget.supplier.phone)
                  _buildChangeRow('Phone', widget.supplier.phone, _phoneController.text),
                if (_emailController.text != widget.supplier.email)
                  _buildChangeRow('Email', widget.supplier.email, _emailController.text),
                if (_addressController.text != widget.supplier.address)
                  _buildChangeRow('Address', widget.supplier.address, _addressController.text),
                if (!_listEquals(_selectedCategories, widget.supplier.categories))
                  _buildChangeRow(
                    'Categories',
                    widget.supplier.categories.join(', '),
                    _selectedCategories.join(', '),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeRow(String field, String oldValue, String newValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              field,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.remove_circle, size: 14, color: Colors.red.shade400),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        oldValue.isEmpty ? '(empty)' : oldValue,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.add_circle, size: 14, color: Colors.green.shade400),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        newValue.isEmpty ? '(empty)' : newValue,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required String originalValue,
    bool required = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
    String? Function(String?)? validator,
  }) {
    final isChanged = controller.text != originalValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            labelText: required ? '$label *' : label,
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isChanged ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isChanged ? Colors.orange : Colors.blue,
                size: 20,
              ),
            ),
            suffixIcon: isChanged
                ? Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: Icon(
                        Icons.undo,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () {
                        controller.text = originalValue;
                      },
                      tooltip: 'Restore original',
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isChanged ? Colors.orange.shade300 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isChanged ? Colors.orange.shade300 : Colors.grey.shade300,
                width: isChanged ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isChanged ? Colors.orange : Colors.blue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: isChanged ? Colors.orange.shade50 : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator ??
              (value) {
                if (required && (value == null || value.trim().isEmpty)) {
                  return '$label is required';
                }
                return null;
              },
        ),
        // Show original value hint when changed
        if (isChanged && originalValue.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  'Original: $originalValue',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected, bool wasOriginal) {
    final isNew = isSelected && !wasOriginal;
    final isRemoved = !isSelected && wasOriginal;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedCategories.remove(category);
              } else {
                _selectedCategories.add(category);
              }
              _checkForChanges();
            });
          },
          borderRadius: BorderRadius.circular(25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isNew ? Colors.green : Colors.blue)
                  : (isRemoved ? Colors.red.shade50 : Colors.white),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? (isNew ? Colors.green : Colors.blue)
                    : (isRemoved ? Colors.red.shade300 : Colors.grey.shade300),
                width: isSelected || isRemoved ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (isNew ? Colors.green : Colors.blue)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(
                    isNew ? Icons.add_circle : Icons.check_circle,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                ] else if (isRemoved) ...[
                  Icon(
                    Icons.remove_circle,
                    color: Colors.red.shade400,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  category,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isRemoved ? Colors.red.shade700 : Colors.grey.shade700),
                    fontWeight: isSelected || isRemoved
                        ? FontWeight.bold
                        : FontWeight.normal,
                    decoration: isRemoved ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (isNew) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Preview
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _hasChanges
                          ? [Colors.orange.shade300, Colors.orange.shade600]
                          : [Colors.blue.shade300, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(_nameController.text),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _nameController.text.isEmpty
                            ? 'Supplier Name'
                            : _nameController.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          if (_hasChanges)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Modified',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              _selectedCategories.isEmpty
                                  ? 'No categories'
                                  : _selectedCategories.join(', '),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Cancel Button
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (await _onWillPop()) {
                      Navigator.pop(context);
                    }
                  },
            child: const Text('Cancel'),
          ),

          const SizedBox(width: 8),

          // Submit Button
          ElevatedButton.icon(
            onPressed: _isSubmitting || !_hasChanges ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSubmitting ? 'Saving...' : 'Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasChanges ? Colors.blue : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
