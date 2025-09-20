class Product{
  final int id;
  final String name;
  final double price;
  final String image;

  Product({required this.id,required this.name,required this.price,required this.image});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      name: json["name"] ?? "",
      price: (json["price"] as num).toDouble(),
      image: (json["thumbnail"] != null && json["thumbnail"] != "")
          ? "https://c16432d24a9a.ngrok-free.app${json["thumbnail"]}"
          : "https://via.placeholder.com/150", // fallback image
    );
  }
}