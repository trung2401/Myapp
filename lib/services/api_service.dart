import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';

class ApiService {
  static const String baseUrl =
      "https://redesigned-barnacle-wrvqj5x7rxggf97gr-8080.app.github.dev/api";

  /// Fetch product theo category
  /// category = "phone" hoặc "laptop"
  static Future<List<Product>> fetchProducts(
      String category, int page, int size) async {
    final url = Uri.parse("$baseUrl/product/$category?page=$page&size=$size");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Lấy mảng items trong data
      final List<dynamic> items = jsonResponse["data"]["items"];

      return items.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception("Lỗi khi fetch $category: ${response.statusCode}");
    }
  }
}
