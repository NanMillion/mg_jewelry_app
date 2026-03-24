class CartItem {
  final String id;
  final String name;
  double price;   // ✅ FIXED (int → double)
  int qty;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
  });

  double get total => price * qty;
}