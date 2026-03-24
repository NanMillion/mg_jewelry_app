import 'package:flutter/material.dart';
import '../../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final service = ProductService();

  final nameCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  bool loading = false;

  Future<void> save() async {
    try {
      setState(() => loading = true);

      await service.addProduct(
        name: nameCtrl.text,
        stock: int.parse(stockCtrl.text),
        price: double.parse(priceCtrl.text),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Add product error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: "Stock")),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Price")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : save,
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}