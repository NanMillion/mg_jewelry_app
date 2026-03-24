import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class FileService {
  final client = Supabase.instance.client;

  // ================= PICK FILE =================
  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return null;

    return File(result.files.single.path!);
  }

  // ================= UPLOAD =================
  Future<String?> upload(File file, String userId) async {
    try {
      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";

      final path = "$userId/$fileName";

      await client.storage.from('task_files').upload(path, file);

      // 🔥 PUBLIC URL
      final url = client.storage.from('task_files').getPublicUrl(path);

      return url;
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }
}