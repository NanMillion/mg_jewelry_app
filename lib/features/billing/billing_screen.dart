import 'package:flutter/material.dart';

import '../../models/cart_item.dart';
import '../../services/inventory_service.dart';
import '../../services/invoice_service.dart';
import '../../services/sales_service.dart';
import '../../services/storage_service.dart';
import '../../services/settings_service.dart';
import '../../services/offline_service.dart';

import '../scan/barcode_scan_screen.dart';
import 'invoice_preview_screen.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final inventory = InventoryService();
  final invoiceService = InvoiceService();
  final salesService = SalesService();
  final storageService = StorageService();
  final settingsService = SettingsService();
  final offline = OfflineService();

  List<Map<String, dynamic>> items = [];
  Map<String, dynamic>? selectedItem;
  final List<CartItem> cart = [];

  final qtyCtrl = TextEditingController(text: "1");
  final customerCtrl = TextEditingController();
  final discountCtrl = TextEditingController();

  bool loading = true;
  bool processing = false;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _loadItems();
    discountCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    qtyCtrl.dispose();
    customerCtrl.dispose();
    discountCtrl.dispose();
    super.dispose();
  }

  // ================= LOAD =================
  Future<void> _loadItems() async {
    try {
      final data = await inventory.fetchItems();

      if (!mounted) return;

      setState(() {
        items = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      showMessage("Failed to load items");
      setState(() => loading = false);
    }
  }

  // ================= BARCODE =================
  Future<void> _scanBarcode() async {
    final code = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BarcodeScanScreen(),
      ),
    );

    if (code == null) return;

    final item = items.firstWhere(
      (e) => e['barcode'] == code,
      orElse: () => {},
    );

    if (item.isEmpty) {
      showMessage("Product not found");
      return;
    }

    _addItemDirect(item);
  }

  void _addItemDirect(Map<String, dynamic> item) {
    final id = item['id'].toString();
    final stock = _toInt(item['quantity']);

    final index = cart.indexWhere((e) => e.id == id);

    if (index != -1) {
      if (cart[index].qty + 1 > stock) {
        return showMessage("Stock limit reached");
      }
      cart[index].qty += 1;
    } else {
      cart.add(
        CartItem(
          id: id,
          name: item['name'],
          price: _toDouble(item['price']),
          qty: 1,
        ),
      );
    }

    setState(() {});
  }

  // ================= CART =================
  void addToCart() {
    if (selectedItem == null) {
      return showMessage("Select item");
    }

    final qty = int.tryParse(qtyCtrl.text) ?? 1;
    final stock = _toInt(selectedItem!['quantity']);

    if (qty <= 0 || qty > stock) {
      return showMessage("Invalid quantity");
    }

    final id = selectedItem!['id'].toString();
    final index = cart.indexWhere((e) => e.id == id);

    if (index != -1) {
      final newQty = cart[index].qty + qty;

      if (newQty > stock) {
        return showMessage("Exceeds stock");
      }

      cart[index].qty = newQty;
    } else {
      cart.add(
        CartItem(
          id: id,
          name: selectedItem!['name'],
          price: _toDouble(selectedItem!['price']),
          qty: qty,
        ),
      );
    }

    setState(() {
      selectedItem = null;
      qtyCtrl.text = "1";
    });
  }

  void remove(int i) => setState(() => cart.removeAt(i));

  void _clearCart() {
    setState(() {
      cart.clear();
      customerCtrl.clear();
      discountCtrl.clear();
    });
  }

  // ================= CALCULATIONS =================
  double get subtotal =>
      cart.fold(0, (sum, item) => sum + item.total);

  double get discount {
    final d = double.tryParse(discountCtrl.text) ?? 0;
    return d.clamp(0, subtotal);
  }

  double get taxable => subtotal - discount;
  double get cgst => taxable * 0.09;
  double get sgst => taxable * 0.09;
  double get total => taxable + cgst + sgst;

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text("Billing POS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _topSection(),
                Expanded(child: _cartList()),
                _totalSection(),
              ],
            ),
    );
  }

  // ================= TOP =================
  Widget _topSection() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _input(customerCtrl, "Customer Name"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Map<String, dynamic>>(
                  value: selectedItem,
                  hint: const Text("Select Item"),
                  items: items.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item['name']),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setState(() => selectedItem = v),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: _input(
                  qtyCtrl,
                  "Qty",
                  type: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: addToCart,
                child: const Text("+"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= CART =================
  Widget _cartList() {
    if (cart.isEmpty) {
      return const Center(
        child: Text("No items",
            style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      itemCount: cart.length,
      itemBuilder: (_, i) {
        final item = cart[i];

        return ListTile(
          title: Text(item.name,
              style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            "${item.qty} x ₹${item.price}",
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "₹${item.total.toStringAsFixed(0)}",
                style: const TextStyle(
                    color: Colors.greenAccent),
              ),
              IconButton(
                icon: const Icon(Icons.delete,
                    color: Colors.red),
                onPressed: () => remove(i),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= TOTAL =================
  Widget _totalSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(color: Colors.black),
      child: Column(
        children: [
          _input(discountCtrl, "Discount ₹",
              type: TextInputType.number),

          _row("Subtotal", subtotal),
          _row("CGST", cgst),
          _row("SGST", sgst),

          const Divider(color: Colors.white24),

          _row("TOTAL", total, big: true),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: processing ? null : createBill,
                  child: processing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Generate Invoice"),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.clear,
                    color: Colors.red),
                onPressed: _clearCart,
              )
            ],
          ),
        ],
      ),
    );
  }

  // ================= CREATE =================
  Future<void> createBill() async {
    if (cart.isEmpty) return showMessage("Add items");

    setState(() => processing = true);

    try {
      final settings = await settingsService.fetchSettings();

      final pdf = await invoiceService.generateInvoice(
        invoiceNo:
            "INV-${DateTime.now().millisecondsSinceEpoch}",
        companyName: settings?.name ?? "",
        companyAddress: settings?.address ?? "",
        gstNumber: settings?.gst ?? "",
        customerName: customerCtrl.text,
        cart: cart,
        subtotal: subtotal,
        discount: discount,
        taxable: taxable,
        cgst: cgst,
        sgst: sgst,
        total: total,
        logoUrl: settings?.logoUrl,
      );

      final url = await storageService.uploadInvoice(pdf);

      try {
        await salesService.addSale(
          name: "Multi Items",
          price: total.toInt(),
          qty: cart.length,
          customer: customerCtrl.text,
          invoiceUrl: url,
        );
      } catch (_) {
        await offline.save({
          'product_name': "Multi Items",
          'price': total.toInt(),
          'quantity': cart.length,
          'total': total,
          'customer': customerCtrl.text,
          'invoice_url': url,
          'created_at': DateTime.now().toIso8601String(),
        });

        showMessage("Saved offline");
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InvoicePreviewScreen(
            customerName: customerCtrl.text,
            itemName: "Multi Items",
            quantity: cart.length,
            price: total,
            pdfBytes: pdf,
            invoiceUrl: url,
          ),
        ),
      );

      _clearCart();
    } catch (e) {
      showMessage("Error: $e");
    }

    if (mounted) setState(() => processing = false);
  }

  // ================= HELPERS =================
  Widget _row(String title, double value,
      {bool big = false}) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white)),
        Text(
          "₹${value.toStringAsFixed(0)}",
          style: TextStyle(
            color: big
                ? Colors.greenAccent
                : Colors.white70,
            fontWeight:
                big ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }

  Widget _input(TextEditingController ctrl, String label,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: label,
        hintStyle:
            const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  int _toInt(dynamic v) =>
      int.tryParse(v.toString()) ?? 0;

  double _toDouble(dynamic v) =>
      double.tryParse(v.toString()) ?? 0;
}