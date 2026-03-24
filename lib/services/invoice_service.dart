import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;

import '../models/cart_item.dart';

class InvoiceService {
  Future<Uint8List> generateInvoice({
    required String invoiceNo,
    required String companyName,
    required String companyAddress,
    required String gstNumber,
    required String customerName,
    required List<CartItem> cart,
    required double subtotal,
    required double discount,
    required double taxable,
    required double cgst,
    required double sgst,
    required double total,
    String? logoUrl,
  }) async {
    final pdf = pw.Document();

    final date =
        DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

    final qrData =
        "INV:$invoiceNo\nCustomer:$customerName\nTotal:₹${total.toStringAsFixed(2)}";

    // 🔥 LOAD LOGO (FIXED)
    pw.Widget? logoWidget;

    if (logoUrl != null && logoUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(logoUrl));

        if (response.statusCode == 200) {
          final image = pw.MemoryImage(response.bodyBytes);

          logoWidget = pw.Container(
            height: 50,
            width: 80,
            child: pw.Image(image),
          );
        }
      } catch (e) {
        // ignore logo error safely
      }
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),

        // ================= BODY =================
        build: (context) => [
          _buildHeader(
            companyName,
            companyAddress,
            gstNumber,
            logoWidget,
          ),

          pw.SizedBox(height: 10),

          _buildInvoiceMeta(invoiceNo, date),

          pw.SizedBox(height: 10),

          pw.Text("Bill To: $customerName"),

          pw.Divider(),

          _buildTable(cart),

          pw.SizedBox(height: 20),

          _buildTotals(
            subtotal,
            discount,
            taxable,
            cgst,
            sgst,
            total,
          ),

          pw.SizedBox(height: 20),

          _buildQR(qrData),

          pw.SizedBox(height: 20),

          pw.Text(
            "Thank you for your business!",
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],

        // ================= FOOTER =================
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            "Page ${context.pageNumber} / ${context.pagesCount}",
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ),
    );

    return pdf.save();
  }

  // ================= HEADER =================
  pw.Widget _buildHeader(
    String name,
    String address,
    String gst,
    pw.Widget? logo,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              name,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(address),
            pw.Text("GSTIN: $gst"),
          ],
        ),

        if (logo != null) logo,
      ],
    );
  }

  // ================= META =================
  pw.Widget _buildInvoiceMeta(String invoiceNo, String date) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text("Invoice No: $invoiceNo"),
        pw.Text("Date: $date"),
      ],
    );
  }

  // ================= TABLE =================
  pw.Widget _buildTable(List<CartItem> cart) {
    if (cart.isEmpty) return pw.Text("No items");

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: [
            _cell("Item", bold: true),
            _cell("Qty", bold: true),
            _cell("Price", bold: true),
            _cell("Total", bold: true),
          ],
        ),
        ...cart.map(
          (item) => pw.TableRow(
            children: [
              _cell(item.name),
              _cell("${item.qty}"),
              _cell("₹${item.price}"),
              _cell("₹${item.total.toStringAsFixed(2)}"),
            ],
          ),
        ),
      ],
    );
  }

  // ================= TOTALS =================
  pw.Widget _buildTotals(
    double subtotal,
    double discount,
    double taxable,
    double cgst,
    double sgst,
    double total,
  ) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 220,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _amountRow("Subtotal", subtotal),
            _amountRow("Discount", discount),

            pw.Divider(),

            _amountRow("Taxable", taxable),
            _amountRow("CGST (9%)", cgst),
            _amountRow("SGST (9%)", sgst),

            pw.Divider(),

            _amountRow("Grand Total", total, bold: true),
          ],
        ),
      ),
    );
  }

  // ================= QR =================
  pw.Widget _buildQR(String qrData) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.BarcodeWidget(
            data: qrData,
            barcode: pw.Barcode.qrCode(),
            width: 100,
            height: 100,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            "Scan for invoice details",
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ================= CELL =================
  pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight:
              bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // ================= AMOUNT =================
  pw.Widget _amountRow(String label, double value,
      {bool bold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label),
        pw.Text(
          "₹${value.toStringAsFixed(2)}",
          style: pw.TextStyle(
            fontWeight:
                bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }
}