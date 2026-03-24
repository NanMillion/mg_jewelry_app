import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/company_settings.dart';

class SettingsService {
  final supabase = Supabase.instance.client;

  Future<CompanySettings?> fetchSettings() async {
    final data = await supabase
        .from('settings')
        .select()
        .limit(1)
        .maybeSingle();

    if (data == null) return null;

    return CompanySettings.fromMap(data);
  }

  Future<void> updateSettings(CompanySettings settings) async {
    final existing = await supabase
        .from('settings')
        .select()
        .limit(1)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('settings').insert(settings.toMap());
    } else {
      await supabase
          .from('settings')
          .update(settings.toMap())
          .eq('id', existing['id']);
    }
  }
}