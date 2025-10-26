import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/add_cart_response.dart';
import 'api_config.dart';
class AddCartApiService {
  final String baseUrl = ApiConfig.baseUrl; // 🔹 đổi lại URL thực tế

  Future<AddCartResponse> addToCart(int variantId, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null || token.isEmpty) {
      throw Exception("Người dùng chưa đăng nhập");
    }

    final url = Uri.parse("$baseUrl/api/cart/add");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "variantId": variantId,
        "quantity": quantity,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AddCartResponse.fromJson(data);
    } else {
      throw Exception("Lỗi server: ${response.statusCode}");
    }
  }
}
