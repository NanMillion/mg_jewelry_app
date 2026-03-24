import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceService {
  final supabase = Supabase.instance.client;

  String? get myId => supabase.auth.currentUser?.id;

  // ================= SET ONLINE =================
  Future<void> setOnline() async {
    if (myId == null) return;

    await supabase.from('online_users').upsert({
      'user_id': myId,
      'is_online': true,
      'last_seen': DateTime.now().toIso8601String(),
    });
  }

  // ================= SET OFFLINE =================
  Future<void> setOffline() async {
    if (myId == null) return;

    await supabase.from('online_users').upsert({
      'user_id': myId,
      'is_online': false,
      'last_seen': DateTime.now().toIso8601String(),
    });
  }

  // ================= STREAM =================
  Stream<List<Map<String, dynamic>>> stream() {
    return supabase
        .from('online_users')
        .stream(primaryKey: ['user_id']);
  }
}