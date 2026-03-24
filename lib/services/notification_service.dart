import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient client = Supabase.instance.client;

  // ================= CURRENT USER =================
  String? get currentUserId => client.auth.currentUser?.id;

  // ================= SEND =================
  Future<void> send({
    required String userId,
    required String title,
    String? body,
    String type = 'task',
  }) async {
    try {
      await client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': false,
      });
    } on PostgrestException catch (e) {
      debugPrint("DB ERROR (sendNotification): ${e.message}");
    } catch (e) {
      debugPrint("UNKNOWN ERROR (sendNotification): $e");
    }
  }

  // ================= STREAM (REALTIME) =================
  Stream<List<Map<String, dynamic>>> stream() {
    final userId = currentUserId;

    if (userId == null) {
      debugPrint("❌ No logged user");
      return const Stream.empty();
    }

    return client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  // ================= UNREAD COUNT =================
  Stream<int> unreadCount() {
    final userId = currentUserId;

    if (userId == null) return const Stream.empty();

    return client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
      final list = List<Map<String, dynamic>>.from(data);
      return list.where((n) => n['is_read'] == false).length;
    });
  }

  // ================= MARK AS READ =================
  Future<void> markRead(String id) async {
    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
    } catch (e) {
      debugPrint("ERROR (markRead): $e");
    }
  }

  // ================= MARK ALL =================
  Future<void> markAllRead() async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint("ERROR (markAllRead): $e");
    }
  }

  // ================= DELETE =================
  Future<void> delete(String id) async {
    try {
      await client.from('notifications').delete().eq('id', id);
    } catch (e) {
      debugPrint("ERROR (deleteNotification): $e");
    }
  }

  // ================= CLEAR ALL =================
  Future<void> clearAll() async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      await client.from('notifications').delete().eq('user_id', userId);
    } catch (e) {
      debugPrint("ERROR (clearAll): $e");
    }
  }
}