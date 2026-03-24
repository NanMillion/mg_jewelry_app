import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  final supabase = Supabase.instance.client;

  // 📊 DAILY SALES
  Future<List<Map<String, dynamic>>> getDailySales() async {
    final res = await supabase
        .from('sales')
        .select()
        .order('created_at');

    final data = List<Map<String, dynamic>>.from(res);

    final Map<String, double> grouped = {};

    for (var item in data) {
      final date =
          DateTime.parse(item['created_at']).toString().substring(0, 10);

      final amount = (item['price'] ?? 0).toDouble();

      grouped[date] = (grouped[date] ?? 0) + amount;
    }

    return grouped.entries
        .map((e) => {"date": e.key, "total": e.value})
        .toList();
  }

  // 💰 TOTAL PROFIT
  Future<double> getTotalSales() async {
    final res = await supabase.from('sales').select('price');

    final data = List<Map<String, dynamic>>.from(res);

    double total = 0;

    for (var item in data) {
      total += (item['price'] ?? 0);
    }

    return total;
  }
}