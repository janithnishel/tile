// lib/widget/quotation_Invoice_screen/quotation_list/material_sale_tab_view.dart

import 'package:flutter/material.dart';
import 'package:tilework/data/material_sale_data.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_list/material_sales_tab_view/material_sale_list_tile.dart';

class MaterialSaleTabView extends StatefulWidget {
  final VoidCallback onCreateNew;
  final Function(MaterialSaleDocument) onDocumentTap;

  const MaterialSaleTabView({
    Key? key,
    required this.onCreateNew,
    required this.onDocumentTap,
  }) : super(key: key);

  @override
  State<MaterialSaleTabView> createState() => _MaterialSaleTabViewState();
}

class _MaterialSaleTabViewState extends State<MaterialSaleTabView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: materialSaleDocuments.isEmpty
          ? _buildEmptyState()
          : _buildDocumentList(),
    );
  }

  Widget _buildDocumentList() {
    // Sort by date (newest first)
    final sortedDocuments = List<MaterialSaleDocument>.from(materialSaleDocuments)
      ..sort((a, b) => b.saleDate.compareTo(a.saleDate));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDocuments.length,
      itemBuilder: (context, index) {
        final document = sortedDocuments[index];
        return MaterialSaleListTile(
          sale: document,
          onTap: () => widget.onDocumentTap(document),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'No material sales yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Create your first material sale',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),

          // Create Button
          ElevatedButton.icon(
            onPressed: widget.onCreateNew,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Create New Sale'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.orange.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        Icons.store,
        size: 80,
        color: Colors.orange.shade400,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Material Sale',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Direct material sales without project association will be available here.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade600,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildComingSoonBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.construction,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: Row for wide screens, Column for narrow
        if (constraints.maxWidth > 500) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FeatureCard(
                icon: Icons.shopping_cart,
                title: 'Quick Sales',
                description: 'Fast checkout process',
                color: Colors.orange,
              ),
              const SizedBox(width: 16),
              _FeatureCard(
                icon: Icons.inventory_2,
                title: 'Inventory',
                description: 'Track stock levels',
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _FeatureCard(
                icon: Icons.receipt_long,
                title: 'Invoices',
                description: 'Generate receipts',
                color: Colors.green,
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FeatureCard(
                    icon: Icons.shopping_cart,
                    title: 'Quick Sales',
                    description: 'Fast checkout',
                    color: Colors.orange,
                    isCompact: true,
                  ),
                  const SizedBox(width: 12),
                  _FeatureCard(
                    icon: Icons.inventory_2,
                    title: 'Inventory',
                    description: 'Track stock',
                    color: Colors.blue,
                    isCompact: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: Icons.receipt_long,
                title: 'Invoices',
                description: 'Generate receipts',
                color: Colors.green,
                isCompact: true,
              ),
            ],
          );
        }
      },
    );
  }
}

// ============================================
// FEATURE CARD WIDGET
// ============================================

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final MaterialColor color;
  final bool isCompact;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? 140 : 140,
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(isCompact ? 10 : 12),
            decoration: BoxDecoration(
              color: color.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color.shade600,
              size: isCompact ? 20 : 24,
            ),
          ),
          SizedBox(height: isCompact ? 8 : 12),

          // Title
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 12 : 14,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 10 : 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
