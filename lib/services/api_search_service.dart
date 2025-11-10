import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';
import 'api_config.dart';

class ApiSearchService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Tìm kiếm sản phẩm theo từ khóa [keyword]
  /// Có thể truyền thêm [page] và [size] để phân trang
  static Future<List<Product>> searchProducts(
      String keyword, int page, int size) async {
    final url = Uri.parse(
        "$baseUrl/api/public/product/search?q=$keyword&page=$page&size=$size");
    print(keyword + page.toString() + size.toString());
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
          "Lỗi khi tìm kiếm sản phẩm: ${response.statusCode} ${response.reasonPhrase}");
    }
  }
}
