import 'package:share_plus/share_plus.dart';

class WhatsAppService {
  static Future<void> send(String phone, String url) async {
    final msg = "🧾 Invoice\n$url";
    await Share.share(msg);
  }
}