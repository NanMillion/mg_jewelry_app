import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final supabase = Supabase.instance.client;

  // ================= FAST FETCH =================
  Future<Map<String, int>> fetchAll({
    required String role,
    String? userId,
  }) async {
    try {
      final res = await supabase.rpc('get_dashboard_stats');

      return {
        'tasks': (res['tasks'] ?? 0) as int,
        'inventory': (res['inventory'] ?? 0) as int,
        'users': (res['users'] ?? 0) as int,
        'value': (res['value'] ?? 0) as int,
        'lowStock': (res['lowStock'] ?? 0) as int,
      };
    } catch (e) {
      debugPrint("Fetch dashboard error: $e");
      return _empty();
    }
  }

  // ================= REALTIME =================
  RealtimeChannel subscribe(VoidCallback onChange) {
    final channel = supabase.channel('dashboard-live');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          callback: (_) => onChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'inventory_items',
          callback: (_) => onChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          callback: (_) => onChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'sales',
          callback: (_) => onChange(),
        )
        .subscribe();

    return channel;
  }

  // ================= DISPOSE =================
  Future<void> dispose(RealtimeChannel channel) async {
    await supabase.removeChannel(channel);
  }

  // ================= EMPTY =================
  Map<String, int> _empty() => {
        'tasks': 0,
        'inventory': 0,
        'users': 0,
        'value': 0,
        'lowStock': 0,
      };
}