class Category {
  final int id;
  final String name;
  final String slug;
  final String categoryType;
  final String? logo; // ảnh có thể null

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.categoryType,
    this.logo,
  });

  String get fullLogoUrl {
    String baseUrl = "https://res.cloudinary.com/doy1zwhge/image/upload";
      return "$baseUrl$logo";
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"],
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
      categoryType: json["categoryType"] ?? "",
      logo: json["logo"], // logo là relative path
    );
  }
}
