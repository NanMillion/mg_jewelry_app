import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final String name;
  final String role;
  final int currentIndex;
  final Function(int) onNavigate;

  const AppSidebar({
    super.key,
    required this.name,
    required this.role,
    required this.currentIndex,
    required this.onNavigate,
  });

  bool get isAdmin => role == 'admin' || role == 'owner';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.account_circle,
                    size: 50, color: Colors.white),
                const SizedBox(height: 10),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 16)),
                Text(role.toUpperCase(),
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          _item("Dashboard", 0, Icons.dashboard),
          _item("Tasks", 1, Icons.task),
          _item("Inventory", 2, Icons.inventory),

          if (isAdmin) _item("Employees", 3, Icons.group),

          _item("Chat", 4, Icons.chat),
          _item("Billing", 5, Icons.point_of_sale),
          _item("Invoices", 6, Icons.receipt_long),

          if (isAdmin)
            _item("Admin Panel", 8, Icons.admin_panel_settings),

          _item("Settings", 7, Icons.settings),
        ],
      ),
    );
  }

  Widget _item(String title, int index, IconData icon) {
    final selected = currentIndex == index;

    return ListTile(
      leading: Icon(icon, color: selected ? Colors.green : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.green : Colors.white,
        ),
      ),
      selected: selected,
      onTap: () => onNavigate(index),
    );
  }
}