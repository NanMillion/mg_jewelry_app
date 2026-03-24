import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OfflineService {
  final supabase = Supabase.instance.client;
  static const boxName = 'offline_sales';

  // ================= SAVE OFFLINE =================
  Future<void> save(Map<String, dynamic> saleData) async {
    final box = Hive.box(boxName);

    await box.add({
      "data": saleData,
      "synced": false,
    });
  }

  // ================= SYNC =================
  Future<void> sync() async {
    final box = Hive.box(boxName);

    for (var key in box.keys) {
      final item = box.get(key);

      if (item['synced'] == false) {
        try {
          await supabase.from('sales').insert(item['data']);

          item['synced'] = true;
          await box.put(key, item);
        } catch (_) {
          // still offline → skip
        }
      }
    }
  }

  // ================= COUNT (optional) =================
  int pendingCount() {
    final box = Hive.box(boxName);
    return box.values
        .where((e) => e['synced'] == false)
        .length;
  }
}