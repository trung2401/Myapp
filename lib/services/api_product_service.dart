import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';
import 'api_config.dart';

class ApiProductService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Fetch products theo category
  /// category = "phone", "laptop", ...
  static Future<List<Product>> fetchProducts(
      String category, int page, int size) async {
    final url = Uri.parse(
        "$baseUrl/api/public/product/filter/$category?page=$page&size=$size");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse["data"] != null &&
          jsonResponse["data"]["items"] != null) {
        final List<dynamic> items = jsonResponse["data"]["items"];
        return items.map((i) => Product.fromJson(i)).toList();
      } else {
        throw Exception("API error code: ${jsonResponse["code"]}");
      }
    } else {
      throw Exception(
          "Lỗi khi fetch $category: ${response.statusCode} ${response.reasonPhrase}");
    }
  }
}
