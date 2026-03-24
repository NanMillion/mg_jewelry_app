import 'package:supabase_flutter/supabase_flutter.dart';

class ClosingService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> today() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final sales = await supabase
        .from('sales')
        .select()
        .gte('created_at', today);

    double total = 0;
    for (var s in sales) {
      total += (s['total'] ?? 0);
    }

    return {
      "count": sales.length,
      "total": total,
    };
  }
}