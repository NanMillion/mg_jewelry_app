class InventoryItem {
  final String name;
  final double weight;

  InventoryItem({required this.name, required this.weight});

  factory InventoryItem.fromJson(Map json) {
    return InventoryItem(
      name: json['name'],
      weight: (json['weight'] as num).toDouble(),
    );
  }
}