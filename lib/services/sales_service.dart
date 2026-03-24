import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalesService {
  final supabase = Supabase.instance.client;

  // ================= ADD SALE =================
  Future<void> addSale({
    required String name,
    required int price,
    required int qty,
    String? customer,
    String? invoiceUrl,
    int? cost,
  }) async {
    try {
      await supabase.from('sales').insert({
        'product_name': name,
        'price': price,
        'quantity': qty,
        'total': price * qty,
        'cost': cost ?? 0,
        'customer': customer ?? 'Walk-in',
        'invoice_url': invoiceUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("❌ Add sale error: $e");
      rethrow;
    }
  }

  // ================= FETCH =================
  Future<List<Map<String, dynamic>>> fetchSales() async {
    try {
      final res = await supabase
          .from('sales')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("❌ Fetch sales error: $e");
      return [];
    }
  }

  // ================= SEARCH =================
  Future<List<Map<String, dynamic>>> searchSales(String query) async {
    try {
      final q = query.trim();
      if (q.isEmpty) return fetchSales();

      final res = await supabase
          .from('sales')
          .select()
          .or('product_name.ilike.%$q%,customer.ilike.%$q%')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("❌ Search error: $e");
      return [];
    }
  }

  // ================= FILTER CORE =================
  Future<List<Map<String, dynamic>>> _getFilteredSales(
      String filter) async {
    try {
      final now = DateTime.now();
      late DateTime start;

      switch (filter) {
        case 'today':
          start = DateTime(now.year, now.month, now.day);
          break;

        case 'week':
          start = now.subtract(const Duration(days: 7));
          break;

        case 'month':
        default:
          start = DateTime(now.year, now.month - 1, now.day);
      }

      final res = await supabase
          .from('sales')
          .select()
          .gte('created_at', start.toIso8601String())
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("❌ Filter error: $e");
      return [];
    }
  }

  // ================= GROUPED SALES =================
  Future<List<Map<String, dynamic>>> getGroupedSales({
    required String filter,
  }) async {
    final raw = await _getFilteredSales(filter);

    final Map<String, double> grouped = {};

    for (final item in raw) {
      final date = item['created_at'].toString().substring(0, 10);

      grouped[date] =
          (grouped[date] ?? 0) + _toDouble(item['total']);
    }

    return grouped.entries
        .map((e) => {
              "date": e.key,
              "total": e.value,
            })
        .toList();
  }

  // ================= PROFIT =================
  Future<double> getProfit({
    required String filter,
  }) async {
    final raw = await _getFilteredSales(filter);

    double sales = 0;
    double cost = 0;

    for (final item in raw) {
      sales += _toDouble(item['total']);
      cost += _toDouble(item['cost']);
    }

    return sales - cost;
  }

  // ================= TOP PRODUCTS =================
  Future<List<Map<String, dynamic>>> getTopProducts({
    int limit = 5,
  }) async {
    try {
      final res = await supabase
          .from('sales')
          .select('product_name, quantity')
          .limit(200);

      final Map<String, int> grouped = {};

      for (final item in res) {
        final name = item['product_name'] ?? 'Unknown';
        final qty = _toInt(item['quantity']);

        grouped[name] = (grouped[name] ?? 0) + qty;
      }

      final list = grouped.entries
          .map((e) => {"name": e.key, "qty": e.value})
          .toList();

      list.sort((a, b) =>
          (b['qty'] as int).compareTo(a['qty'] as int));

      return list.take(limit).toList();
    } catch (e) {
      debugPrint("❌ Top products error: $e");
      return [];
    }
  }

  // ================= TOP CUSTOMERS =================
  Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 5,
  }) async {
    try {
      final res = await supabase
          .from('sales')
          .select('customer, total')
          .limit(300);

      final Map<String, double> grouped = {};

      for (final item in res) {
        final name = item['customer'] ?? 'Walk-in';
        final total = _toDouble(item['total']);

        grouped[name] =
            (grouped[name] ?? 0) + total;
      }

      final list = grouped.entries
          .map((e) => {"name": e.key, "amount": e.value})
          .toList();

      list.sort((a, b) =>
          _toDouble(b['amount']).compareTo(_toDouble(a['amount'])));

      return list.take(limit).toList();
    } catch (e) {
      debugPrint("❌ Top customers error: $e");
      return [];
    }
  }

  // ================= QUICK STATS =================
  Future<double> getTotalRevenue() async {
    try {
      final res =
          await supabase.from('sales').select('total');

      double total = 0;
      for (final item in res) {
        total += _toDouble(item['total']);
      }

      return total;
    } catch (e) {
      debugPrint("❌ Revenue error: $e");
      return 0;
    }
  }

  Future<int> getTotalOrders() async {
    try {
      final res =
          await supabase.from('sales').select('id');

      return res.length;
    } catch (e) {
      debugPrint("❌ Orders error: $e");
      return 0;
    }
  }

  // ================= HELPERS =================
  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}