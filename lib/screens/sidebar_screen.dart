import 'package:flutter/material.dart';
import 'package:tilework/screens/dashboard_screen.dart';
import 'package:tilework/widget/shared/menu_item.dart';
import 'package:tilework/screens/job_cost_section.dart';
import 'package:tilework/screens/quotation_Invoice/quotation_list_screen.dart';
import 'package:tilework/screens/purchase_order_screen.dart';
import 'package:tilework/screens/reports_screen.dart';

class SidebarScreen extends StatefulWidget {
  @override
  _SidebarScreenState createState() => _SidebarScreenState();
}

class _SidebarScreenState extends State<SidebarScreen> {
  bool isExpanded = true;
  int selectedIndex = 0;
  late final List<MenuItem> menuItems;

  @override
  void initState() {
    super.initState();
    menuItems = [
      MenuItem(
        icon: Icons.home,
        title: 'Dashboard',
        onTap: () => _navigateToPage(0),
      ),
      MenuItem(
        icon: Icons.person,
        title: 'Quotation/Invoice',
        onTap: () => _navigateToPage(1),
      ),
      MenuItem(
        icon: Icons.receipt_long,
        title: 'Purchase Order',
        onTap: () => _navigateToPage(2),
      ),
      MenuItem(
        icon: Icons.mail,
        title: 'Job Cost',
        onTap: () => _navigateToPage(3),
      ),
      MenuItem(
        icon: Icons.bar_chart,
        title: 'Reports',
        onTap: () => _navigateToPage(4),
      ),
      MenuItem(
        icon: Icons.notifications,
        title: 'Notifications',
        onTap: () => _navigateToPage(5),
        badgeCount: 3, // Example badge
        badgeColor: Colors.red,
      ),
      MenuItem(
        icon: Icons.settings,
        title: 'Settings',
        onTap: () => _navigateToPage(6),
      ),
      MenuItem(
        icon: Icons.logout,
        title: 'Logout',
        onTap: () => _handleLogout(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: isExpanded ? 250 : 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.blue.shade700, width: 1),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: AnimatedSize(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: AnimatedOpacity(
                            opacity: isExpanded ? 1.0 : 0.0,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: isExpanded
                                ? Text(
                                    'Dashboard',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: Icon(
                            isExpanded
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Items
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: selectedIndex == index
                                    ? Colors.blue.shade600
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    menuItems[index].icon,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  AnimatedOpacity(
                                    opacity: isExpanded ? 1.0 : 0.0,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: AnimatedContainer(
                                      width: isExpanded ? 16 : 0,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                  Flexible(
                                    child: AnimatedSize(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      child: AnimatedOpacity(
                                        opacity: isExpanded ? 1.0 : 0.0,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        child: isExpanded
                                            ? Text(
                                                menuItems[index].title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight:
                                                      selectedIndex == index
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              )
                                            : Container(width: 0, height: 0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  // App Bar
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          menuItems[selectedIndex].title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: getPage(selectedIndex),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _handleLogout() {
    // TODO: Implement logout logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add logout logic here
              Navigator.of(context).pop();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget getPage(int index) {
    switch (index) {
      case 0:
        return DashboardScreen();
      case 1:
        return QuotationListScreen();
      case 2:
        return PurchaseOrderScreen();
      case 3:
        return JobCostScreen();
      case 4:
        return ReportsScreen();

      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                menuItems[selectedIndex].icon,
                size: 80,
                color: Colors.blue.shade600,
              ),
              SizedBox(height: 24),
              Text(
                'You selected: ${menuItems[selectedIndex].title}',
                style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'This is your ${menuItems[selectedIndex].title} page content area. Add your widgets here!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        );
    }
  }
}
