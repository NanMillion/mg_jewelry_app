import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/sales_service.dart';
import '../billing/invoice_preview_screen.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  State<InvoiceHistoryScreen> createState() =>
      _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  final service = SalesService();

  List<Map<String, dynamic>> sales = [];
  bool loading = true;

  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  // ================= LOAD =================
  Future<void> load() async {
    if (!mounted) return;

    setState(() => loading = true);

    try {
      final data = await service.fetchSales();

      if (!mounted) return;

      setState(() {
        sales = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("Load error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= SEARCH =================
  Future<void> search(String query) async {
    final q = query.trim();

    if (q.isEmpty) {
      load();
      return;
    }

    try {
      final data = await service.searchSales(q);

      if (!mounted) return;

      setState(() => sales = data);
    } catch (e) {
      debugPrint("Search error: $e");
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoice History")),
      body: Column(
        children: [
          _searchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ================= SEARCH BAR =================
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: searchCtrl,
        decoration: InputDecoration(
          hintText: "Search customer / product",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchCtrl.clear();
                    FocusScope.of(context).unfocus();
                    load();
                  },
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {}); // refresh suffix icon
          search(value);
        },
      ),
    );
  }

  // ================= BODY =================
  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sales.isEmpty) {
      return const Center(
        child: Text(
          "No invoices found",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: sales.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => _invoiceTile(sales[i]),
      ),
    );
  }

  // ================= TILE =================
  Widget _invoiceTile(Map<String, dynamic> s) {
    final name = (s['product_name'] ?? 'Unknown').toString();
    final customer = (s['customer'] ?? 'Customer').toString();

    final qty = _toInt(s['quantity']);
    final total = _toInt(s['total']);
    final invoiceUrl = s['invoice_url']?.toString();

    final date = s['created_at'] != null
        ? DateTime.tryParse(s['created_at'])
        : null;

    final formattedDate = date != null
        ? DateFormat('dd MMM yyyy').format(date)
        : '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),

      leading: const CircleAvatar(
        child: Icon(Icons.receipt_long),
      ),

      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$customer • Qty: $qty"),
          if (formattedDate.isNotEmpty)
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),

      trailing: Text(
        "₹$total",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),

      onTap: () => _openInvoice(
        name,
        customer,
        qty,
        total,
        invoiceUrl,
      ),
    );
  }

  // ================= OPEN INVOICE =================
  void _openInvoice(
    String name,
    String customer,
    int qty,
    int total,
    String? invoiceUrl,
  ) {
    if (invoiceUrl == null || invoiceUrl.isEmpty) {
      showMessage("Invoice file not available");
      return;
    }

    final price = qty == 0 ? 0 : (total ~/ qty);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoicePreviewScreen(
          customerName: customer,
          itemName: name,
          quantity: qty,
          price: price.toDouble(),
          pdfBytes: Uint8List(0),
          invoiceUrl: invoiceUrl,
        ),
      ),
    );
  }

  // ================= SNACKBAR =================
  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ================= SAFE INT =================
  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}