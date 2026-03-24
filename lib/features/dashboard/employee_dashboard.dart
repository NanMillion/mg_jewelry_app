import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/dashboard_service.dart';

// ✅ widgets
import 'package:mg_jewelry/features/dashboard/widgets/premium_card.dart';

class EmployeeDashboard extends StatefulWidget {
  final String name;

  const EmployeeDashboard({super.key, required this.name});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final DashboardService service = DashboardService();

  Map<String, int> data = {};
  bool loading = true;
  String? error;

  RealtimeChannel? channel;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _load();

    // 🔴 Realtime updates
    channel = service.subscribe(_load);
  }

  // ================= LOAD =================
  Future<void> _load() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final result = await service.fetchAll(
        role: 'employee',
        userId: user.id,
      );

      if (!mounted) return;

      setState(() {
        data = result;
        loading = false;
      });
    } catch (e) {
      debugPrint("Employee dashboard error: $e");

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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    // 🔄 LOADING
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ❌ ERROR
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

    return Scaffold(
      body: Container(
        // 🔥 GLASS BACKGROUND
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
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER =================
                const Text(
                  "👷 Employee Dashboard",
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

                // ================= PREMIUM ANALYTICS =================
                Row(
                  children: [
                    PremiumCard(
                      title: "Revenue",
                      value: "₹${data['value'] ?? 0}",
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    PremiumCard(
                      title: "Tasks",
                      value: "${data['tasks'] ?? 0}",
                      color: Colors.blue,
                    ),
                  ],
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
                        leading: Icon(Icons.task, color: Colors.white),
                        title: Text(
                          "View Tasks",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Divider(height: 1, color: Colors.white12),
                      ListTile(
                        leading: Icon(Icons.update, color: Colors.white),
                        title: Text(
                          "Update Work Status",
                          style: TextStyle(color: Colors.white),
                        ),
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