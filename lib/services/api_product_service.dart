import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';
import 'api_config.dart';

class ApiProductService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Fetch danh sách sản phẩm theo category + các filter
  static Future<List<Product>> fetchProducts({
    required String categorySlug,
    int page = 1,
    int size = 20,
    String order = "id",
    String dir = "asc",
    double priceFrom = 0,
    double priceTo = 1000000000,
    Map<String, String>? params, // thêm bộ lọc từ filter_bottom_sheet
  }) async {
    // 🔹 Xây dựng query parameters
    final queryParams = {
      "order": order,
      "dir": dir,
      "page": "$page",
      "size": "$size",
      "price_from": "$priceFrom",
      "price_to": "$priceTo",
    };

    // 🔹 Gắn thêm các filters từ người dùng chọn (nếu có)
    if (params != null && params.isNotEmpty) {
      queryParams.addAll(params);
    }

    // 🔹 Tạo URL hoàn chỉnh
    final uri = Uri.parse("$baseUrl/api/public/product/filter/$categorySlug")
        .replace(queryParameters: queryParams);

    print("📡 Gọi API: $uri"); // Debug xem URL đúng chưa

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse["data"] != null &&
          jsonResponse["data"]["items"] != null) {
        final List<dynamic> items = jsonResponse["data"]["items"];
        return items.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception("API error code: ${jsonResponse["code"]}");
      }
    } else {
      throw Exception(
          "Lỗi khi fetch $categorySlug: ${response.statusCode} ${response.reasonPhrase}");
    }
  }
}
