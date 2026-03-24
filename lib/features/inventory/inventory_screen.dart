import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/inventory_service.dart';
import '../../services/user_service.dart';
import '../../utils/permission_helper.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService service = InventoryService();
  final UserService userService = UserService();

  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filtered = [];

  Map<String, dynamic>? perms;

  bool loading = true;
  String? error;

  final TextEditingController searchCtrl = TextEditingController();

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _loadPermissions();
    await _loadItems();
  }

  // ================= PERMISSIONS =================
  Future<void> _loadPermissions() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final res = await userService.getPermissions(user.id);

      if (!mounted) return;

      setState(() => perms = res);
    } catch (e) {
      debugPrint("❌ Permission Error: $e");
    }
  }

  bool get canAccess => PermissionHelper.canInventory(perms);
  bool get canEdit => PermissionHelper.canInventory(perms);

  // ================= LOAD =================
  Future<void> _loadItems() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final data = await service.fetchItems();

      if (!mounted) return;

      setState(() {
        items = List<Map<String, dynamic>>.from(data);
        filtered = items;
        loading = false;
      });
    } catch (e) {
      debugPrint("❌ Load Error: $e");

      if (!mounted) return;

      setState(() {
        error = "Failed to load inventory";
        loading = false;
      });
    }
  }

  // ================= SEARCH =================
  void _search(String text) {
    final q = text.toLowerCase();

    setState(() {
      filtered = items.where((item) {
        final name = (item['name'] ?? '')
            .toString()
            .toLowerCase();
        return name.contains(q);
      }).toList();
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (loading || perms == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!canAccess) {
      return const Center(
        child: Text("🚫 Access Denied"),
      );
    }

    if (error != null) {
      return _errorUI();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),

      body: Column(
        children: [
          _header(),
          _searchBar(),

          Expanded(
            child: filtered.isEmpty
                ? _emptyState()
                : RefreshIndicator(
                    onRefresh: _loadItems,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final item = filtered[i];

                        return _itemCard(item);
                      },
                    ),
                  ),
          ),
        ],
      ),

      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () => _showForm(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.inventory, color: Colors.white),
          SizedBox(width: 10),
          Text(
            "Inventory",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: searchCtrl,
        onChanged: _search,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search items...",
          hintStyle:
              const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white10,
          prefixIcon:
              const Icon(Icons.search, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= ITEM CARD =================
  Widget _itemCard(Map<String, dynamic> item) {
    final id = item['id'].toString();
    final name = item['name'] ?? '';
    final qty = item['quantity'] ?? 0;
    final price = item['price'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                _stockColor(qty).withOpacity(0.2),
            child: Icon(Icons.inventory,
                color: _stockColor(qty)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Qty: $qty • ₹$price",
                    style: const TextStyle(
                        color: Colors.white70)),
              ],
            ),
          ),

          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit,
                  color: Colors.white),
              onPressed: () =>
                  _showForm(item: item),
            ),

          if (canEdit)
            IconButton(
              icon: const Icon(Icons.delete,
                  color: Colors.red),
              onPressed: () =>
                  _confirmDelete(id),
            ),
        ],
      ),
    );
  }

  // ================= STATES =================
  Widget _emptyState() {
    return const Center(
      child: Text(
        "No items found",
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _errorUI() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error!,
              style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _loadItems,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  // ================= STOCK COLOR =================
  Color _stockColor(int qty) {
    if (qty == 0) return Colors.red;
    if (qty < 5) return Colors.orange;
    return Colors.green;
  }

  // ================= FORM =================
  Future<void> _showForm(
      {Map<String, dynamic>? item}) async {
    final nameCtrl =
        TextEditingController(text: item?['name'] ?? '');
    final qtyCtrl = TextEditingController(
        text: item?['quantity']?.toString() ?? '');
    final priceCtrl = TextEditingController(
        text: item?['price']?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            Text(item == null ? "Add Item" : "Edit Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl),
            TextField(controller: qtyCtrl),
            TextField(controller: priceCtrl),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final data = {
                "name": nameCtrl.text.trim(),
                "quantity":
                    int.tryParse(qtyCtrl.text) ?? 0,
                "price":
                    int.tryParse(priceCtrl.text) ?? 0,
              };

              if (item == null) {
                await service.addItem(data);
              } else {
                await service.updateItem(
                    item['id'], data);
              }

              if (!mounted) return;

              Navigator.pop(context);
              _loadItems();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= DELETE =================
  Future<void> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await service.deleteItem(id);
      _loadItems();
    }
  }
}