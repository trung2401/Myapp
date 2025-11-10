import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product.dart';
import 'api_config.dart';

class GetFavoriteService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// 🧡 Lấy danh sách sản phẩm yêu thích (có phân trang)
  static Future<List<Product>> fetchFavoriteProducts(int page, int size) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null || token.isEmpty) {
      throw Exception("Người dùng chưa đăng nhập");
    }

    final url = Uri.parse("$baseUrl/api/customer/my-liked?page=$page&size=$size");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse["data"] != null &&
          jsonResponse["data"]["items"] != null) {
        final List<dynamic> items = jsonResponse["data"]["items"];
        return items.map((i) => Product.fromJson(i)).toList();
      } else {
        throw Exception("API trả về dữ liệu rỗng hoặc sai cấu trúc");
      }
    } else {
      throw Exception(
          "Lỗi khi lấy danh sách sản phẩm yêu thích: ${response.statusCode}");
    }
  }

  static Future<void> likeProduct(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null || token.isEmpty) {
      throw Exception("Người dùng chưa đăng nhập");
    }

    final url = Uri.parse("$baseUrl/api/interaction/like/$productId");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Lỗi khi like sản phẩm: ${response.statusCode}");
    }
  }

  static Future<void> unlikeProduct(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null || token.isEmpty) {
      throw Exception("Người dùng chưa đăng nhập");
    }

    final url = Uri.parse("$baseUrl/api/interaction/unlike/$productId");
    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Lỗi khi bỏ like sản phẩm: ${response.statusCode}");
    }
  }


}
