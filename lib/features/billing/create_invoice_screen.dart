import 'package:flutter/material.dart';
import '../../services/inventory_service.dart';
import '../../services/sales_service.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final inventoryService = InventoryService();
  final salesService = SalesService();

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> cart = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await inventoryService.fetchItems();

    setState(() {
      products = data;
      loading = false;
    });
  }

  // ================= ADD TO CART =================
  void _addToCart(Map<String, dynamic> product) {
    final index = cart.indexWhere((e) => e['id'] == product['id']);

    if (index != -1) {
      cart[index]['qty'] += 1;
    } else {
      cart.add({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'qty': 1,
      });
    }

    setState(() {});
  }

  // ================= TOTAL =================
  int get total {
    int sum = 0;
    for (final item in cart) {
      sum += (item['price'] as int) * (item['qty'] as int);
    }
    return sum;
  }

  // ================= SAVE =================
  Future<void> _saveSale() async {
    if (cart.isEmpty) return;

    for (final item in cart) {
      await salesService.addSale(
        name: item['name'],
        price: item['price'],
        qty: item['qty'],
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invoice Saved")),
    );

    setState(() {
      cart.clear();
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Invoice"),
      ),
      body: Row(
        children: [
          // ================= PRODUCT LIST =================
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i];

                return ListTile(
                  title: Text(p['name']),
                  subtitle: Text("₹${p['price']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addToCart(p),
                  ),
                );
              },
            ),
          ),

          // ================= CART =================
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black12,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Cart",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (_, i) {
                        final item = cart[i];

                        return ListTile(
                          title: Text(item['name']),
                          subtitle: Text(
                              "₹${item['price']} x ${item['qty']}"),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          "Total: ₹$total",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _saveSale,
                          child: const Text("Save Invoice"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}