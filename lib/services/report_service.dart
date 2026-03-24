import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ReportService {
  final _currency = NumberFormat.currency(symbol: "₹", decimalDigits: 0);
  final _date = DateFormat("dd MMM yyyy");

  // ================= PDF REPORT =================
  Future<File> generatePdfReport(
      List<Map<String, dynamic>> sales) async {
    final pdf = pw.Document();

    final totalSum = sales.fold<double>(
      0,
      (sum, e) => sum + _toDouble(e['total']),
    );

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Text(
                "MG Jewelry",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 4),

              pw.Text(
                "Sales Report • ${_date.format(DateTime.now())}",
                style: const pw.TextStyle(fontSize: 12),
              ),

              pw.SizedBox(height: 16),

              // TABLE
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                headers: ["Product", "Qty", "Total"],
                data: sales.map((e) {
                  return [
                    (e['product_name'] ?? '').toString(),
                    _toInt(e['quantity']).toString(),
                    _currency.format(_toDouble(e['total'])),
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 20),

              // TOTAL
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    "Total: ${_currency.format(totalSum)}",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    return await _saveFile(bytes, "sales_report.pdf");
  }

  // ================= EXCEL REPORT =================
  Future<File> generateExcelReport(
      List<Map<String, dynamic>> sales) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sales'];

    // HEADER
    sheet.appendRow(["Product", "Qty", "Total"]);

    double total = 0;

    for (final item in sales) {
      final qty = _toInt(item['quantity']);
      final price = _toDouble(item['total']);

      total += price;

      sheet.appendRow([
        (item['product_name'] ?? '').toString(),
        qty,
        price,
      ]);
    }

    // TOTAL ROW
    sheet.appendRow([]);
    sheet.appendRow(["", "TOTAL", total]);

    final bytes = excel.encode();
    return await _saveFile(bytes!, "sales_report.xlsx");
  }

  // ================= SHARE =================
  Future<void> shareFile(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: "MG Jewelry Sales Report",
    );
  }

  // ================= SAVE FILE =================
  Future<File> _saveFile(List<int> bytes, String name) async {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/$name");
    await file.writeAsBytes(bytes);
    return file;
  }

  // ================= HELPERS =================
  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}