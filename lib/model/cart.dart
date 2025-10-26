class CartResponse {
  final int code;
  final String message;
  final String timestamp;
  final List<CartItem> data;

  CartResponse({
    required this.code,
    required this.message,
    required this.timestamp,
    required this.data,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'timestamp': timestamp,
    'data': data.map((e) => e.toJson()).toList(),
  };
}

class CartItem {
  final int id;
  final Item item;
  int quantity; // có thể thay đổi khi người dùng nhấn +/-

  CartItem({
    required this.id,
    required this.item,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      item: Item.fromJson(json['item'] ?? {}),
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'item': item.toJson(),
    'quantity': quantity,
  };
}

class Item {
  final int id;
  final String sku;
  final String thumbnail;
  final double price;
  final double specialPrice;
  final List<ItemAttribute> attributes;
  final int availableStock;

  Item({
    required this.id,
    required this.sku,
    required this.thumbnail,
    required this.price,
    required this.specialPrice,
    required this.attributes,
    required this.availableStock,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? 0,
      sku: json['sku'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      specialPrice: (json['specialPrice'] as num?)?.toDouble() ?? 0.0,
      attributes: (json['attributes'] as List<dynamic>? ?? [])
          .map((e) => ItemAttribute.fromJson(e))
          .toList(),
      availableStock: json['availableStock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sku': sku,
    'thumbnail': thumbnail,
    'price': price,
    'specialPrice': specialPrice,
    'attributes': attributes.map((e) => e.toJson()).toList(),
    'availableStock': availableStock,
  };
}

class ItemAttribute {
  final String code;
  final String label;
  final String value;

  ItemAttribute({
    required this.code,
    required this.label,
    required this.value,
  });

  factory ItemAttribute.fromJson(Map<String, dynamic> json) {
    return ItemAttribute(
      code: json['code'] ?? '',
      label: json['label'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'label': label,
    'value': value,
  };
}
