import 'package:myapp/model/product.dart';
import 'package:myapp/model/product_detail_info.dart';

class ProductDetail {
  final int id;
  final String name;
  final String description;
  final String slug;
  final String thumbnail;
  final Promotion? promotion;
  final bool available;
  final List<Variant> variants;
  final List<Media> medias;
  final Rating rating;
  final ProductDetailInfo detail;

  ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.slug,
    required this.thumbnail,
    this.promotion,
    required this.available,
    required this.variants,
    required this.medias,
    required this.rating,
    required this.detail,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json["id"],
      name: json["name"],
      description: json["description"] ?? "",
      slug: json["slug"],
      thumbnail: json["thumbnail"] ?? "",
      promotion: json["promotion"] != null ? Promotion.fromJson(json["promotion"]) : null,
      available: json["available"] ?? true,
      variants: (json["variants"] as List<dynamic>?)
          ?.map((v) => Variant.fromJson(v))
          .toList() ??
          [],
      medias: (json["medias"] as List<dynamic>?)
          ?.map((m) => Media.fromJson(m))
          .toList() ??
          [],
      rating: json["rating"] != null
          ? Rating.fromJson(json["rating"])
          : Rating(total: 0, average: 0.0),
      detail: json["detail"] != null
          ? ProductDetailInfo.fromJson(json["detail"])
          : ProductDetailInfo(displaySize: '', screenTechnology: '', cameraRear: '', cameraFront: '', chipset: '', nfc: '', storage: '', battery: '', sim: '', osVersion: '', displayResolution: '', displayFeatures: '', cpuType: ''), // hoặc tùy bạn có default constructor
    );
  }
}

class Variant {
  final int id;
  final String sku;
  final String thumbnail;
  final double price;
  final double specialPrice;
  final List<ProductAttribute> attributes;
  final int availableStock;

  Variant({
    required this.id,
    required this.sku,
    required this.thumbnail,
    required this.price,
    required this.specialPrice,
    required this.attributes,
    required this.availableStock,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json["id"],
      sku: json["sku"],
      thumbnail: json["thumbnail"] ?? "",
      price: (json["price"] as num).toDouble(),
      specialPrice: (json["specialPrice"] as num).toDouble(),
      availableStock: json["availableStock"] ?? 0,
      attributes: (json["attributes"] as List<dynamic>?)
          ?.map((a) => ProductAttribute.fromJson(a))
          .toList() ??
          [],
    );
  }
}

class ProductAttribute {
  final String code;
  final String label;
  final String value;

  ProductAttribute({
    required this.code,
    required this.label,
    required this.value,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      code: json["code"],
      label: json["label"],
      value: json["value"],
    );
  }
}

class Media {
  final int id;
  final String mediaType;
  final String url;
  final String altText;

  Media({
    required this.id,
    required this.mediaType,
    required this.url,
    required this.altText,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json["id"],
      mediaType: json["mediaType"],
      url: json["url"],
      altText: json["altText"] ?? "",
    );
  }
}
