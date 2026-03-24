import 'dart:typed_data';

import 'export_service_mobile.dart'
  if (dart.library.html) 'export_service_web.dart';

class ExportService {
  // ================= DOWNLOAD =================
  static Future<void> download(Uint8List bytes, String filename) {
    return downloadFile(bytes, filename);
  }

  // ================= CSV EXPORT =================
  static Future<void> exportCSV(List<Map<String, dynamic>> data) async {
    String csv = "Product,Qty,Price,Total\n";

    for (var row in data) {
      csv +=
          "${row['product_name']},${row['quantity']},${row['price']},${row['total']}\n";
    }

    final bytes = Uint8List.fromList(csv.codeUnits);
    await download(bytes, "sales_report.csv");
  }
}