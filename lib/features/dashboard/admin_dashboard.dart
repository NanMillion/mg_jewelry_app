import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/dashboard_service.dart';

// widgets
import 'package:mg_jewelry/features/dashboard/widgets/revenue_card.dart';
import 'package:mg_jewelry/features/dashboard/widgets/sales_chart.dart';
import 'package:mg_jewelry/features/dashboard/widgets/top_products_chart.dart';

// 🔥 NEW widgets
import 'package:mg_jewelry/features/dashboard/widgets/profit_card.dart';
import 'package:mg_jewelry/features/dashboard/widgets/pie_chart.dart';
import 'package:mg_jewelry/features/dashboard/widgets/premium_card.dart';

// 🔥 HERO
import 'package:mg_jewelry/core/hero_wrapper.dart';
import 'package:mg_jewelry/features/dashboard/screens/detail_screen.dart';

class AdminDashboard extends StatefulWidget {
  final String name;

  const AdminDashboard({super.key, required this.name});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DashboardService service = DashboardService();

  Map<String, int> data = {};
  bool loading = true;
  String? error;

  RealtimeChannel? channel;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _load();
    channel = service.subscribe(_load);
  }

  // ================= LOAD =================
  Future<void> _load() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final result = await service.fetchAll(
        role: 'admin',
        userId: user.id,
      );

      if (!mounted) return;

      setState(() {
        data = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      debugPrint("❌ Admin dashboard error: $e");

      if (!mounted) return;

      setState(() {
        error = "Failed to load dashboard";
        loading = false;
      });
    }
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    if (channel != null) {
      service.dispose(channel!);
    }
    super.dispose();
  }

  // ================= SMOOTH ROUTE =================
  Route _smoothRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _load,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final revenue = (data['value'] ?? 0).toDouble();
    final expense = (data['expense'] ?? 0).toDouble();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF020617),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER =================
                const Text(
                  "🛠 Admin Dashboard",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Welcome, ${widget.name}",
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 20),

                // ================= HERO PREMIUM CARDS =================
                Row(
                  children: [
                    // 🔥 REVENUE
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            _smoothRoute(
                              DetailScreen(
                                title: "Revenue",
                                value: "₹${data['value'] ?? 0}",
                                tag: "revenue_card",
                              ),
                            ),
                          );
                        },
                        child: HeroWrapper(
                          tag: "revenue_card",
                          child: PremiumCard(
                            title: "Revenue",
                            value: "₹${data['value'] ?? 0}",
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 🔥 ORDERS
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            _smoothRoute(
                              DetailScreen(
                                title: "Orders",
                                value: "${data['tasks'] ?? 0}",
                                tag: "orders_card",
                              ),
                            ),
                          );
                        },
                        child: HeroWrapper(
                          tag: "orders_card",
                          child: PremiumCard(
                            title: "Orders",
                            value: "${data['tasks'] ?? 0}",
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 🔥 USERS
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            _smoothRoute(
                              DetailScreen(
                                title: "Users",
                                value: "${data['users'] ?? 0}",
                                tag: "users_card",
                              ),
                            ),
                          );
                        },
                        child: HeroWrapper(
                          tag: "users_card",
                          child: PremiumCard(
                            title: "Users",
                            value: "${data['users'] ?? 0}",
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= PROFIT =================
                ProfitCard(
                  revenue: revenue,
                  expense: expense,
                ),

                const SizedBox(height: 20),

                // ================= REVENUE =================
                RevenueCard(revenue: revenue),

                const SizedBox(height: 20),

                // ================= PIE CHART =================
                DashboardPieChart(
                  revenue: data['value'] ?? 0,
                  orders: data['tasks'] ?? 0,
                  users: data['users'] ?? 0,
                ),

                const SizedBox(height: 20),

                // ================= SALES CHART =================
                const SalesChart(
                  data: [
                    {"date": "2026-03-01", "revenue": 1200, "orders": 30},
                    {"date": "2026-03-02", "revenue": 1800, "orders": 45},
                    {"date": "2026-03-03", "revenue": 900, "orders": 20},
                  ],
                ),

                const SizedBox(height: 20),

                // ================= TOP PRODUCTS =================
                TopProductsChart(
                  data: [
                    {"name": "Ring", "qty": data['rings'] ?? 0},
                    {"name": "Chain", "qty": data['chains'] ?? 0},
                    {"name": "Bangle", "qty": data['bangles'] ?? 0},
                  ],
                ),

                const SizedBox(height: 20),

                // ================= LOW STOCK =================
                Card(
                  color: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    title: const Text(
                      "Low Stock Items",
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      (data['lowStock'] ?? 0).toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= QUICK ACTIONS =================
                Card(
                  color: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.inventory, color: Colors.white),
                        title: Text("Manage Inventory",
                            style: TextStyle(color: Colors.white)),
                      ),
                      Divider(height: 1, color: Colors.white12),
                      ListTile(
                        leading: Icon(Icons.group, color: Colors.white),
                        title: Text("Manage Employees",
                            style: TextStyle(color: Colors.white)),
                      ),
                      Divider(height: 1, color: Colors.white12),
                      ListTile(
                        leading: Icon(Icons.receipt, color: Colors.white),
                        title: Text("View Orders",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}