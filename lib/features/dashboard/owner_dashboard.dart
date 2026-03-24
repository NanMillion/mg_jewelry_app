import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/dashboard_service.dart';

// widgets
import 'package:mg_jewelry/features/dashboard/widgets/revenue_card.dart';
import 'package:mg_jewelry/features/dashboard/widgets/sales_chart.dart';
import 'package:mg_jewelry/features/dashboard/widgets/top_products_chart.dart';
import 'package:mg_jewelry/features/dashboard/widgets/stacked_chart.dart';
import 'package:mg_jewelry/features/dashboard/widgets/heatmap_widget.dart';

// 🔥 NEW widgets
import 'package:mg_jewelry/features/dashboard/widgets/profit_card.dart';
import 'package:mg_jewelry/features/dashboard/widgets/pie_chart.dart';
import 'package:mg_jewelry/features/dashboard/widgets/premium_card.dart';

// 🔥 HERO
import 'package:mg_jewelry/core/hero_wrapper.dart';
import 'package:mg_jewelry/features/dashboard/screens/detail_screen.dart';

class OwnerDashboard extends StatefulWidget {
  final String name;

  const OwnerDashboard({super.key, required this.name});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  final DashboardService service = DashboardService();

  Map<String, int> data = {};
  bool loading = true;
  String? error;

  RealtimeChannel? channel;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _load();
    channel = service.subscribe(_load);
  }

  Future<void> _load() async {
    try {
      final result = await service.fetchAll(role: 'owner');

      if (!mounted) return;

      setState(() {
        data = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });

      debugPrint("❌ Owner dashboard error: $e");
    }
  }

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
          child: Text(
            "Error: $error",
            style: const TextStyle(color: Colors.red),
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
                  "👑 Owner Panel",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Welcome ${widget.name}",
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
                SalesChart(
                  data: [
                    {
                      "date": "Day 1",
                      "revenue": data['value'] ?? 0,
                      "orders": data['tasks'] ?? 0,
                    },
                    {
                      "date": "Day 2",
                      "revenue": (data['value'] ?? 0) ~/ 2,
                      "orders": (data['tasks'] ?? 0) ~/ 2,
                    },
                    {
                      "date": "Day 3",
                      "revenue": (data['value'] ?? 0) + 200,
                      "orders": (data['tasks'] ?? 0) + 5,
                    },
                  ],
                ),

                const SizedBox(height: 20),

                // ================= ADVANCED =================
                const Text(
                  "Sales Breakdown",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),
                const StackedChart(),

                const SizedBox(height: 20),

                // ================= HEATMAP =================
                const Text(
                  "Weekly Activity",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),
                const HeatmapWidget(
                  data: [
                    [0.2, 0.5, 0.7, 0.3, 0.8, 0.9, 0.4],
                    [0.1, 0.6, 0.4, 0.7, 0.2, 0.5, 0.3],
                  ],
                ),

                const SizedBox(height: 20),

                // ================= TOP PRODUCTS =================
                TopProductsChart(
                  data: [
                    {"name": "Gold Ring", "qty": data['rings'] ?? 0},
                    {"name": "Necklace", "qty": data['necklace'] ?? 0},
                    {"name": "Chain", "qty": data['chains'] ?? 0},
                  ],
                ),

                const SizedBox(height: 20),

                // ================= LOW STOCK =================
                _lowStockCard(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= LOW STOCK =================
  Widget _lowStockCard() {
    final lowStock = data['lowStock'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lowStock > 0
            ? Colors.red.withOpacity(0.2)
            : Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            lowStock > 0 ? Icons.warning : Icons.check_circle,
            color: lowStock > 0 ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lowStock > 0
                  ? "⚠ Low Stock Items: $lowStock"
                  : "✔ Stock levels are healthy",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: lowStock > 0 ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}