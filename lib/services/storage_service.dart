import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient supabase = Supabase.instance.client;

  static const String bucket = 'invoices';

  // ================= GENERIC UPLOAD =================
  Future<String> _uploadFile({
    required Uint8List bytes,
    required String path,
  }) async {
    try {
      await supabase.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false, // ❌ prevent overwrite
            ),
          );

      return supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint("Upload error: $e");
      throw Exception("Upload failed");
    }
  }

  // ================= INVOICE UPLOAD =================
  Future<String> uploadInvoice(Uint8List bytes) async {
    final fileName =
        "invoices/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf";

    return _uploadFile(
      bytes: bytes,
      path: fileName,
    );
  }

  // ================= LOGO UPLOAD =================
  Future<String> uploadLogo(Uint8List bytes) async {
    final fileName =
        "logos/logo_${DateTime.now().millisecondsSinceEpoch}.png";

    return _uploadFile(
      bytes: bytes,
      path: fileName,
    );
  }
}