import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ================= SIGN UP =================
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();

      final res = await supabase.auth.signUp(
        email: normalizedEmail,
        password: password,
      );

      final user = res.user;

      // 🔥 Ensure profile exists
      if (user != null) {
        await _ensureProfile(user);
      }

      return user;
    } catch (e) {
      debugPrint("❌ SignUp Error: $e");
      return null;
    }
  }

  // ================= SIGN IN =================
  Future<(User user, String role)?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();

      final res = await supabase.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = res.user;
      if (user == null) return null;

      final profile = await _ensureProfile(user);

      final role = (profile?['role'] ?? 'employee').toString();

      return (user, role);
    } catch (e) {
      debugPrint("❌ SignIn Error: $e");
      return null;
    }
  }

  // ================= LOGOUT =================
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      debugPrint("❌ SignOut Error: $e");
    }
  }

  // ================= CURRENT USER =================
  User? get currentUser => supabase.auth.currentUser;

  // ================= ENSURE PROFILE =================
  Future<Map<String, dynamic>?> _ensureProfile(User user) async {
    try {
      // 🔍 Check if profile exists
      final existing = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // 🆕 If not exists → create
      if (existing == null) {
        await supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'role': 'employee',
          'created_at': DateTime.now().toIso8601String(),
        });

        final created = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        return created;
      }

      // ✅ Already exists
      return existing;
    } catch (e) {
      debugPrint("❌ EnsureProfile Error: $e");
      return null;
    }
  }
}