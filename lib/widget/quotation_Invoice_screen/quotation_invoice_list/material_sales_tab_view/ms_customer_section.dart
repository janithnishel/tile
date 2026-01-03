// lib/widget/material_sale/sections/ms_customer_section.dart

import 'package:flutter/material.dart';

class MSCustomerSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController? addressController;
  final bool isEditable;
  final bool isSearching;
  final VoidCallback? onSearchByPhone;
  final VoidCallback? onClearFields;

  const MSCustomerSection({
    Key? key,
    required this.nameController,
    required this.phoneController,
    this.addressController,
    this.isEditable = true,
    this.isSearching = false,
    this.onSearchByPhone,
    this.onClearFields,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          _buildSectionHeader(),
          const SizedBox(height: 16),

          // Phone Number with Search
          _buildPhoneField(context),
          const SizedBox(height: 12),

          // Customer Name
          _buildNameField(),
          
          // Address (Optional)
          if (addressController != null) ...[
            const SizedBox(height: 12),
            _buildAddressField(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.person_outline,
            color: Colors.orange.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Customer Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (!isEditable)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Locked',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    return TextFormField(
      controller: phoneController,
      enabled: isEditable,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Phone Number *',
        hintText: '07X XXX XXXX',
        prefixIcon: const Icon(Icons.phone_outlined),
        suffixIcon: isEditable
            ? Container(
                width: 96, // Wider to accommodate both buttons
                height: 48,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search button
                    if (isSearching)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                        ),
                      )
                    else if (onSearchByPhone != null)
                      IconButton(
                        icon: Icon(Icons.search, color: Colors.orange.shade600),
                        onPressed: onSearchByPhone,
                        tooltip: 'Search existing customer',
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),

                    // Clear button (only show if there are values to clear)
                    if (onClearFields != null && (nameController.text.isNotEmpty || (addressController?.text.isNotEmpty ?? false)))
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.red.shade400),
                        onPressed: onClearFields,
                        tooltip: 'Clear all customer fields',
                        iconSize: 18,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: nameController,
      enabled: isEditable,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Customer Name *',
        hintText: 'Enter customer name',
        prefixIcon: const Icon(Icons.badge_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: addressController,
      enabled: isEditable,
      maxLines: 2,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Address (Optional)',
        hintText: 'Enter customer address',
        prefixIcon: const Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
        ),
      ),
    );
  }
}
