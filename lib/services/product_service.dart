import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  Future<void> addProduct({
    required String name,
    required int stock,
    required double price,
  }) async {
    await supabase.from('products').insert({
      'name': name,
      'stock': stock,
      'price': price,
    });
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final res = await supabase.from('products').select();
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> updateStock(String id, int newStock) async {
    await supabase
        .from('products')
        .update({'stock': newStock})
        .eq('id', id);
  }
}