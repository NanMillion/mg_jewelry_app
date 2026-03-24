import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BillingService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ================= CREATE BILL =================
  Future<bool> createBill({
    required String itemId,
    required String itemName,
    required int quantity,
    required int price,
    String? customer,
    String? invoiceUrl,
  }) async {
    try {
      // ================= VALIDATION =================
      if (quantity <= 0) {
        throw Exception("Invalid quantity");
      }

      // ================= FETCH ITEM =================
      final item = await supabase
          .from('inventory_items')
          .select('quantity')
          .eq('id', itemId)
          .single();

      final currentQty = _toInt(item['quantity']);

      if (currentQty < quantity) {
        throw Exception("Not enough stock");
      }

      final total = price * quantity;

      // ================= INSERT SALE =================
      await supabase.from('sales').insert({
        'product_name': itemName,
        'quantity': quantity,
        'price': price,
        'total': total,
        'customer': customer ?? 'Walk-in',
        'invoice_url': invoiceUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      // ================= UPDATE STOCK =================
      await supabase.from('inventory_items').update({
        'quantity': currentQty - quantity,
      }).eq('id', itemId);

      return true;
    } catch (e) {
      debugPrint("❌ CreateBill Error: $e");
      return false;
    }
  }

  // ================= MULTI ITEM BILL =================
  Future<bool> createMultiBill({
    required List<Map<String, dynamic>> items,
    String? customer,
    String? invoiceUrl,
  }) async {
    try {
      for (final item in items) {
        final id = item['id'].toString();
        final name = item['name'];
        final qty = _toInt(item['quantity']);
        final price = _toInt(item['price']);

        final success = await createBill(
          itemId: id,
          itemName: name,
          quantity: qty,
          price: price,
          customer: customer,
          invoiceUrl: invoiceUrl,
        );

        if (!success) {
          throw Exception("Failed to create bill");
        }
      }

      return true;
    } catch (e) {
      debugPrint("❌ MultiBill Error: $e");
      return false;
    }
  }

  // ================= HELPERS =================
  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}