import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class GoldRateService {
  static const _box = 'app_cache';

  Future<double> get22KRate() async {
    final cache = await Hive.openBox(_box);

    try {
      final res = await http.get(
        Uri.parse('https://api.metals.live/v1/spot/gold'),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final usdPerOz = (data[0]['gold'] as num).toDouble();

        // convert approx USD/oz → ₹/gram (you can refine)
        final inrPerGram = usdPerOz * 83 / 31.1;
        final rate22k = inrPerGram * 0.916;

        await cache.put('gold_rate_22k', rate22k);
        return rate22k;
      }
    } catch (_) {}

    // fallback to cached
    return cache.get('gold_rate_22k', defaultValue: 0.0);
  }
}