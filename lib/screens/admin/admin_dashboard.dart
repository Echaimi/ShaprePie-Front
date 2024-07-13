import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatelessWidget {
  final Widget child;

  const AdminDashboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard',
            style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0), // Light grey border
            width: 1.0,
          ),
        ),
      ),
      body: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(
                top: 24.0, right: 16.0, left: 16.0, bottom: 24.0),
            width: 250,
            decoration: const BoxDecoration(
              color: Color(0xFFF8F8F8), // Light grey background
              border: Border(
                right: BorderSide(
                  color: Color(0xFFE0E0E0), // Light grey border
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildSidebarItem(
                  context,
                  icon: Icons.category,
                  label: 'Categories',
                  index: 0,
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.tag,
                  label: 'Tags',
                  index: 1,
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.people,
                  label: 'Users',
                  index: 2,
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.event,
                  label: 'Events',
                  index: 3,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                  top: 24.0, right: 24.0, left: 24.0, bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/admin/categories')) {
      return 0;
    }
    if (location.startsWith('/admin/tags')) {
      return 1;
    }
    if (location.startsWith('/admin/users')) {
      return 2;
    }
    if (location.startsWith('/admin/events')) {
      return 3;
    }
    return 0;
  }

  Widget _buildSidebarItem(BuildContext context,
      {required IconData icon, required String label, required int index}) {
    final bool isSelected = _getSelectedIndex(context) == index;

    return InkWell(
      onTap: () {
        if (index == 0) {
          context.go('/admin/categories');
        } else if (index == 1) {
          context.go('/admin/tags');
        } else if (index == 2) {
          context.go('/admin/users');
        } else if (index == 3) {
          context.go('/admin/events');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE0E0E0)
              : Colors.transparent, // Light grey background for selected item
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.black : Colors.grey),
            const SizedBox(width: 16.0),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
