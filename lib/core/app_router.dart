import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/login_screen.dart';
import '../features/navigation/main_navigation.dart'; // 🔥 NEW

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final user = supabase.auth.currentUser;

    // ❌ Not logged in → go login
    if (user == null) {
      _go(const LoginScreen());
      return;
    }

    try {
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      if (!mounted) return;

      // ✅ Navigate to MainNavigation (Instagram UI)
      _go(
        MainNavigation(
          name: user.email ?? '',
          role: profile['role'] ?? 'employee',
        ),
      );
    } catch (e) {
      debugPrint("Router error: $e");

      if (!mounted) return;

      _go(const LoginScreen());
    }
  }

  void _go(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}