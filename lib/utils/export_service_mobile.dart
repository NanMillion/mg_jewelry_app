import 'dart:io';
import 'package:share_plus/share_plus.dart';

Future<void> downloadFile(List<int> bytes, String filename) async {
  final file = File("/storage/emulated/0/Download/$filename");
  await file.writeAsBytes(bytes);

  await Share.shareXFiles([XFile(file.path)]);
}