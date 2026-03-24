import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/export_service.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final String customerName;
  final String itemName;
  final int quantity;
  final double price;
  final Uint8List pdfBytes;
  final String? invoiceUrl;

  const InvoicePreviewScreen({
    super.key,
    required this.customerName,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.pdfBytes,
    this.invoiceUrl,
  });

  double get subtotal => quantity * price;
  double get gst => subtotal * 0.18;
  double get total => subtotal + gst;

  String _format(double v) => "₹${v.toStringAsFixed(2)}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice"),
        actions: [
          IconButton(
            tooltip: "Print",
            icon: const Icon(Icons.print),
            onPressed: _print,
          ),
          IconButton(
            tooltip: "Share",
            icon: const Icon(Icons.share),
            onPressed: _share,
          ),
          IconButton(
            tooltip: "Download",
            icon: const Icon(Icons.download),
            onPressed: _download,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= HEADER =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "MG JEWELRY",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy')
                              .format(DateTime.now()),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Customer: $customerName",
                      style: const TextStyle(fontSize: 14),
                    ),

                    const Divider(height: 30),

                    // ================= TABLE HEADER =================
                    const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text("Item")),
                        SizedBox(width: 10),
                        Text("Qty"),
                        SizedBox(width: 10),
                        Text("Price"),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ================= ITEM =================
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(itemName)),
                        Text("$quantity"),
                        Text(_format(price)),
                      ],
                    ),

                    const Divider(height: 30),

                    // ================= TOTAL =================
                    _row("Subtotal", subtotal),
                    _row("GST (18%)", gst),
                    _row("Total", total, bold: true),

                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        "Thank you for your business!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= OPTIONAL LINK =================
                    if (invoiceUrl != null)
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: invoiceUrl!));
                          },
                          child: const Text("Copy Invoice Link"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= ROW =================
  Widget _row(String title, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            _format(value),
            style: TextStyle(
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  // ================= PRINT =================
  Future<void> _print() async {
    try {
      if (invoiceUrl != null) {
        final data = await NetworkAssetBundle(
                Uri.parse(invoiceUrl!))
            .load(invoiceUrl!);

        await Printing.layoutPdf(
          onLayout: (_) async => data.buffer.asUint8List(),
        );
      } else {
        await Printing.layoutPdf(
          onLayout: (_) async => pdfBytes,
        );
      }
    } catch (e) {
      debugPrint("❌ Print error: $e");
    }
  }

  // ================= SHARE =================
  Future<void> _share() async {
    try {
      if (invoiceUrl != null) {
        await Share.share(invoiceUrl!);
      } else {
        await Share.shareXFiles([
          XFile.fromData(pdfBytes, name: "invoice.pdf"),
        ]);
      }
    } catch (e) {
      debugPrint("❌ Share error: $e");
    }
  }

  // ================= DOWNLOAD =================
  void _download() {
    try {
      ExportService.download(pdfBytes, "invoice.pdf");
    } catch (e) {
      debugPrint("❌ Download error: $e");
    }
  }
}