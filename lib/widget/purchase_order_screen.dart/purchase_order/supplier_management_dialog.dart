import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/supplier/supplier_cubit.dart';
import 'package:tilework/cubits/supplier/supplier_state.dart';
import 'package:tilework/models/purchase_order_screen/supplier.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/add_supplier_dialog.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/edit_supplier_dialog.dart';

class SupplierManagementDialog extends StatefulWidget {
  const SupplierManagementDialog({Key? key}) : super(key: key);

  @override
  State<SupplierManagementDialog> createState() => _SupplierManagementDialogState();
}

class _SupplierManagementDialogState extends State<SupplierManagementDialog> {
  late SupplierCubit _supplierCubit;
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store references safely to avoid context issues
    _supplierCubit = context.read<SupplierCubit>();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    // Load suppliers when dialog opens
    _supplierCubit.loadSuppliers();
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSupplierDialog(
        onAdd: (supplier) async {
          try {
            await _supplierCubit.createSupplier(supplier);
            if (mounted) {
              _scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Supplier "${supplier.name}" added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              _scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Failed to add supplier: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditSupplierDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => EditSupplierDialog(
        supplier: supplier,
        onEdit: (updatedSupplier) async {
          try {
            await _supplierCubit.updateSupplier(updatedSupplier);
            if (mounted) {
              _scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Supplier "${updatedSupplier.name}" updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              _scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Failed to update supplier: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Are you sure you want to delete "${supplier.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              try {
                await _supplierCubit.deleteSupplier(supplier.id);
                if (mounted) {
                  _scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Supplier "${supplier.name}" deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  _scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete supplier: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Manage Suppliers'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _showAddSupplierDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildSupplierList(),
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
          const Icon(Icons.business, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Manage Suppliers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _showAddSupplierDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierList() {
    return BlocBuilder<SupplierCubit, SupplierState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading suppliers',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<SupplierCubit>().loadSuppliers(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.suppliers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.business, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No suppliers found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first supplier to get started',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.suppliers.length,
          itemBuilder: (context, index) {
            final supplier = state.suppliers[index];
            return _buildSupplierCard(supplier);
          },
        );
      },
    );
  }

  Widget _buildSupplierCard(Supplier supplier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Text(
            supplier.initials,
            style: TextStyle(
              color: Colors.teal.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(supplier.phone),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                supplier.category,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditSupplierDialog(supplier),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(supplier),
            ),
          ],
        ),
      ),
    );
  }
}
