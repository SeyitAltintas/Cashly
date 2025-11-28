class Asset {
  final String id;
  final String name;
  final double amount;
  final double quantity;
  final String category;
  final String? type;
  final DateTime lastUpdated;
  bool isDeleted;

  Asset({
    required this.id,
    required this.name,
    required this.amount,
    this.quantity = 1.0,
    required this.category,
    this.type,
    required this.lastUpdated,
    this.isDeleted = false,
  });
}
