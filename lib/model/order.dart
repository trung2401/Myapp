class Order {
  final int id;
  final String status;
  final double totalAmount;
  final double discountAmount;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.discountAmount,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      items: (json['items'] as List<dynamic>)
          .map((i) => OrderItem.fromJson(i))
          .toList(),
    );
  }
}

class OrderItem {
  final int id;
  final String name;
  final String sku;
  final String thumbnail;
  final double price;
  final double specialPrice;
  final int quantity;

  OrderItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.thumbnail,
    required this.price,
    required this.specialPrice,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      specialPrice: (json['specialPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
    );
  }
}
