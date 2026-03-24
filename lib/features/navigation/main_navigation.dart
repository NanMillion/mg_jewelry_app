import 'dart:ui';
import 'package:flutter/material.dart';

// dashboards
import 'package:mg_jewelry/features/dashboard/owner_dashboard.dart';
import 'package:mg_jewelry/features/dashboard/admin_dashboard.dart';
import 'package:mg_jewelry/features/dashboard/employee_dashboard.dart';

// 🔥 FAB SCREENS
import 'package:mg_jewelry/features/inventory/inventory_screen.dart';
import 'package:mg_jewelry/features/employees/employees_screen.dart';
import 'package:mg_jewelry/features/tasks/task_screen.dart';

class MainNavigation extends StatefulWidget {
  final String name;
  final String role;

  const MainNavigation({
    super.key,
    required this.name,
    required this.role,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;
  bool fabOpen = false;

  late final List<Widget> pages;
  late final PageController _pageController;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: index);

    if (widget.role == 'owner') {
      pages = [
        OwnerDashboard(name: widget.name),
        const Center(child: Text("Reports")),
        const Center(child: Text("Settings")),
      ];
    } else if (widget.role == 'admin') {
      pages = [
        AdminDashboard(name: widget.name),
        const Center(child: Text("Inventory")),
        const Center(child: Text("Settings")),
      ];
    } else {
      pages = [
        EmployeeDashboard(name: widget.name),
        const Center(child: Text("Tasks")),
        const Center(child: Text("Profile")),
      ];
    }
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔥 SWIPE NAVIGATION
          PageView(
            controller: _pageController,
            onPageChanged: (i) {
              setState(() => index = i);
            },
            children: pages,
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _glassNavBar(),
          ),
        ],
      ),
    );
  }

  // ================= GLASS NAV =================
  Widget _glassNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(Icons.home, 0),
              _navItem(Icons.bar_chart, 1),

              _fabButton(),

              _navItem(Icons.notifications, 2),
              _navItem(Icons.person, 2),
            ],
          ),
        ),
      ),
    );
  }

  // ================= NAV ITEM (RIPPLE + ANIMATION) =================
  Widget _navItem(IconData icon, int i) {
    final active = index == i;

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () {
        _pageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.9, end: active ? 1.2 : 1),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.white12 : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: active ? Colors.orange : Colors.white70,
          ),
        ),
      ),
    );
  }

  // ================= FAB BUTTON =================
  Widget _fabButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (fabOpen) ...[
          _fabItem(Icons.inventory, -70, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InventoryScreen()),
            );
          }),
          _fabItem(Icons.group, -130, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EmployeesScreen(role: widget.role),
              ),
            );
          }),
          _fabItem(Icons.task, -190, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskScreen(role: widget.role),
              ),
            );
          }),
        ],

        GestureDetector(
          onTap: () {
            setState(() => fabOpen = !fabOpen);
          },
          child: AnimatedRotation(
            turns: fabOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.8),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ================= FAB ITEM =================
  Widget _fabItem(
    IconData icon,
    double offsetY,
    VoidCallback onTap,
  ) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: fabOpen ? offsetY.abs() : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: fabOpen ? 1 : 0,
        child: GestureDetector(
          onTap: () {
            setState(() => fabOpen = false);
            onTap();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black87,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.6),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}