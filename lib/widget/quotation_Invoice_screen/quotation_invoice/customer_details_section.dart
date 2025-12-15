import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomerDetailsSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController projectTitleController;
  final bool isEditable;
  final bool showSearchButton;
  final VoidCallback? onSearchByPhone;
  final VoidCallback? onNameChanged;
  final String? Function(String?)? phoneValidator;

  const CustomerDetailsSection({
    Key? key,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.projectTitleController,
    required this.isEditable,
    this.showSearchButton = false,
    this.onSearchByPhone,
    this.onNameChanged,
    this.phoneValidator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Phone Field with Search Button
        _buildPhoneField(),
        const SizedBox(height: 12),

        // Customer Name
        _buildTextField(
          controller: nameController,
          label: 'Customer Name',
          icon: Icons.person,
          hintText: 'Enter customer full name',
          onChanged: (_) => onNameChanged?.call(),
        ),
        const SizedBox(height: 12),

        // Address
        _buildTextField(
          controller: addressController,
          label: 'Service/Billing Address',
          icon: Icons.location_on,
          hintText: 'Enter complete address',
        ),
        const SizedBox(height: 12),

        // Project Title
        _buildTextField(
          controller: projectTitleController,
          label: 'Project Title',
          icon: Icons.work_outline,
          hintText: 'Enter project description or title',
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    if (showSearchButton) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Customer Phone (Unique Key)',
                hintText: 'Enter customer phone number',
                prefixIcon: const Icon(Icons.phone),
                border: const OutlineInputBorder(),
                filled: !isEditable,
                fillColor: isEditable ? null : Colors.grey.shade100,
                helperText: 'Enter phone number to search existing customer',
                helperStyle: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
                errorText: phoneValidator != null ? phoneValidator!(phoneController.text) : null,
              ),
              readOnly: !isEditable,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Only allow digits
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isEditable ? onSearchByPhone : null,
              icon: const Icon(Icons.search, size: 20),
              label: const Text('Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      );
    } else {
      return TextField(
        controller: phoneController,
        decoration: InputDecoration(
          labelText: 'Customer Phone',
          hintText: 'Enter customer phone number',
          prefixIcon: const Icon(Icons.phone),
          border: const OutlineInputBorder(),
          filled: !isEditable,
          fillColor: isEditable ? null : Colors.grey.shade100,
          errorText: phoneValidator != null ? phoneValidator!(phoneController.text) : null,
        ),
        readOnly: !isEditable,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Only allow digits
        ],
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: !isEditable,
        fillColor: isEditable ? null : Colors.grey.shade100,
      ),
      readOnly: !isEditable,
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}
