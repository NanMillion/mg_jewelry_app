import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUserService {
  final supabase = Supabase.instance.client;

  // 🔥 CREATE USER (admin API)
  Future<void> createUser({
    required String email,
    required String password,
  }) async {
    await supabase.auth.admin.createUser(
      AdminUserAttributes(
        email: email,
        password: password,
        emailConfirm: true,
      ),
    );
  }

  // 🔥 FETCH USERS
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final res = await supabase
        .from('profiles')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  // 🔥 UPDATE ROLE
  Future<void> updateRole({
    required String id,
    required String role,
  }) async {
    await supabase.from('profiles').update({'role': role}).eq('id', id);
  }

  // 🔥 DELETE USER (soft: remove profile only)
  Future<void> deleteUser(String id) async {
    await supabase.from('profiles').delete().eq('id', id);
  }
}