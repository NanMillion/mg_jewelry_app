import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerService {
  final db = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetch() async {
    final res = await db.from('customers').select().order('created_at');
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> add(String name, String phone) async {
    await db.from('customers').insert({
      'name': name,
      'phone': phone,
    });
  }
}