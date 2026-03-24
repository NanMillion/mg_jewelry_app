class Product {
  final String id;
  final String name;
  final int stock;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.stock,
    required this.price,
  });

  factory Product.fromMap(Map data) {
    return Product(
      id: data['id'],
      name: data['name'],
      stock: data['stock'],
      price: (data['price'] as num).toDouble(),
    );
  }
}