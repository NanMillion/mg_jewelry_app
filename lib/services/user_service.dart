import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ================= CURRENT PROFILE =================
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final res = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return res != null ? Map<String, dynamic>.from(res) : null;
    } catch (e) {
      debugPrint("❌ GetProfile Error: $e");
      return null;
    }
  }

  // ================= FETCH ALL USERS =================
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      final res = await supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("❌ FetchUsers Error: $e");
      return [];
    }
  }

  // ================= FETCH USER BY ID =================
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final res = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return res != null ? Map<String, dynamic>.from(res) : null;
    } catch (e) {
      debugPrint("❌ GetUserById Error: $e");
      return null;
    }
  }

  // ================= UPDATE ROLE =================
  Future<bool> updateRole({
    required String userId,
    required String role,
  }) async {
    try {
      await supabase
          .from('profiles')
          .update({'role': role})
          .eq('id', userId);

      return true;
    } catch (e) {
      debugPrint("❌ UpdateRole Error: $e");
      return false;
    }
  }

  // ================= UPDATE PROFILE =================
  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null && name.isNotEmpty) {
        data['name'] = name;
      }

      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }

      if (data.isEmpty) return true;

      await supabase
          .from('profiles')
          .update(data)
          .eq('id', userId);

      return true;
    } catch (e) {
      debugPrint("❌ UpdateProfile Error: $e");
      return false;
    }
  }

  // ================= DELETE USER =================
  Future<bool> deleteUser(String userId) async {
    try {
      await supabase
          .from('profiles')
          .delete()
          .eq('id', userId);

      return true;
    } catch (e) {
      debugPrint("❌ DeleteUser Error: $e");
      return false;
    }
  }

  // ================= GET PERMISSIONS =================
  Future<Map<String, dynamic>?> getPermissions(String userId) async {
    try {
      final res = await supabase
          .from('permissions')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return res != null ? Map<String, dynamic>.from(res) : null;
    } catch (e) {
      debugPrint("❌ GetPermissions Error: $e");
      return null;
    }
  }

  // ================= UPSERT PERMISSIONS =================
  Future<bool> savePermissions({
    required String userId,
    bool canManageInventory = false,
    bool canManageBilling = false,
    bool canManageUsers = false,
    bool canViewReports = false,
    bool canCreateInvoice = false,
  }) async {
    try {
      await supabase.from('permissions').upsert({
        'user_id': userId,
        'can_manage_inventory': canManageInventory,
        'can_manage_billing': canManageBilling,
        'can_manage_users': canManageUsers,
        'can_view_reports': canViewReports,
        'can_create_invoice': canCreateInvoice,
      });

      return true;
    } catch (e) {
      debugPrint("❌ SavePermissions Error: $e");
      return false;
    }
  }
}