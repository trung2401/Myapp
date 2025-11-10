class Review {
  final int id;
  final String content;
  final Customer customer;
  final int productId;
  final DateTime createdAt;
  final int rating;
  final List<ReviewMedia> medias;
  final bool purchased;

  Review({
    required this.id,
    required this.content,
    required this.customer,
    required this.productId,
    required this.createdAt,
    required this.rating,
    required this.medias,
    required this.purchased,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      content: json['content'] ?? "",
      customer: Customer.fromJson(json['customer']),
      productId: json['productId'],
      createdAt: DateTime.parse(json['createdAt']),
      rating: json['rating'],
      medias: (json['medias'] as List<dynamic>?)
          ?.map((m) => ReviewMedia.fromJson(m))
          .toList() ??
          [],
      purchased: json['purchased'] ?? false,
    );
  }
}

class Customer {
  final int id;
  final String name;

  Customer({required this.id, required this.name});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'] ?? "Ẩn danh",
    );
  }
}

class ReviewMedia {
  final int id;
  final String mediaType;
  final String url;
  final String? altText;

  ReviewMedia({
    required this.id,
    required this.mediaType,
    required this.url,
    this.altText,
  });

  factory ReviewMedia.fromJson(Map<String, dynamic> json) {
    return ReviewMedia(
      id: json['id'],
      mediaType: json['mediaType'] ?? "",
      url: json['url'] ?? "",
      altText: json['altText'],
    );
  }
}
