import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ================= FETCH ALL =================
  Future<List<Map<String, dynamic>>> fetchItems() async {
    try {
      final res = await supabase
          .from('inventory_items')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("❌ FetchItems Error: $e");
      return [];
    }
  }

  // ================= SEARCH =================
  Future<List<Map<String, dynamic>>> searchItems(String query) async {
    try {
      if (query.trim().isEmpty) return fetchItems();

      final res = await supabase
          .from('inventory_items')
          .select()
          .ilike('name', '%$query%')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("❌ SearchItems Error: $e");
      return [];
    }
  }

  // ================= ADD ITEM =================
  Future<bool> addItem(Map<String, dynamic> data) async {
    try {
      final item = {
        'name': data['name'] ?? '',
        'quantity': _toInt(data['quantity']),
        'price': _toDouble(data['price']),
        'barcode': data['barcode'],
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('inventory_items').insert(item);
      return true;
    } catch (e) {
      debugPrint("❌ AddItem Error: $e");
      return false;
    }
  }

  // ================= UPDATE ITEM =================
  Future<bool> updateItem(String id, Map<String, dynamic> data) async {
    try {
      final updated = {
        if (data['name'] != null) 'name': data['name'],
        if (data['quantity'] != null)
          'quantity': _toInt(data['quantity']),
        if (data['price'] != null)
          'price': _toDouble(data['price']),
        if (data['barcode'] != null) 'barcode': data['barcode'],
      };

      if (updated.isEmpty) return true;

      await supabase
          .from('inventory_items')
          .update(updated)
          .eq('id', id);

      return true;
    } catch (e) {
      debugPrint("❌ UpdateItem Error: $e");
      return false;
    }
  }

  // ================= DELETE ITEM =================
  Future<bool> deleteItem(String id) async {
    try {
      await supabase
          .from('inventory_items')
          .delete()
          .eq('id', id);

      return true;
    } catch (e) {
      debugPrint("❌ DeleteItem Error: $e");
      return false;
    }
  }

  // ================= GET SINGLE ITEM =================
  Future<Map<String, dynamic>?> getItemById(String id) async {
    try {
      final res = await supabase
          .from('inventory_items')
          .select()
          .eq('id', id)
          .maybeSingle();

      return res != null ? Map<String, dynamic>.from(res) : null;
    } catch (e) {
      debugPrint("❌ GetItem Error: $e");
      return null;
    }
  }

  // ================= REALTIME STREAM =================
  Stream<List<Map<String, dynamic>>> streamItems() {
    return supabase
        .from('inventory_items')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // ================= HELPERS =================
  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}