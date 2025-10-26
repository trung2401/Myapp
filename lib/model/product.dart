class Product {
  final int id;
  final String name;
  final String slug;
  final String thumbnail;
  final double price;
  final double specialPrice;
  final int stock;
  final int availableStock;
  final Promotion? promotion;
  final Rating rating;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.thumbnail,
    required this.price,
    required this.specialPrice,
    required this.stock,
    required this.availableStock,
    this.promotion,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      thumbnail: json['thumbnail'],
      price: (json['price'] as num).toDouble(),
      specialPrice: json['special_price'] != null
          ? (json['special_price'] as num).toDouble()
          : (json['price'] as num).toDouble(),
      stock: json['stock'],
      availableStock: json['available_stock'],
      promotion: json['promotion'] != null
          ? Promotion.fromJson(json['promotion'])
          : null,
      rating: json['rating'] != null
          ? Rating.fromJson(json['rating'])
          : Rating(total: 0, average: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'thumbnail': thumbnail,
      'price': price,
      'special_price': specialPrice,
      'stock': stock,
      'available_stock': availableStock,
      'promotion': promotion?.toJson(),
      'rating': rating.toJson(),
    };
  }
}

class Promotion {
  final int id;
  final String name;
  final String description;
  final String discountType;
  final double discountValue;
  final String startDate;
  final String endDate;
  final String status;
  final String scope;

  Promotion({
    required this.id,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.scope,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      discountType: json['discountType'],
      discountValue: (json['discountValue'] as num).toDouble(),
      startDate: json['startDate'],
      endDate: json['endDate'],
      status: json['status'],
      scope: json['scope'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'scope': scope,
    };
  }
}

class Rating {
  final int total;
  final double average;

  Rating({required this.total, required this.average});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      total: json['total'] ?? 0,
      average: json['average'] != null
          ? (json['average'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'average': average,
    };
  }
}
