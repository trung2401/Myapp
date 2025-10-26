import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/cart.dart';
import 'api_config.dart';

class CartService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<CartResponse> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null || token.isEmpty) {
      throw Exception("Người dùng chưa đăng nhập");
    }

    final url = Uri.parse("$baseUrl/api/cart/my-cart");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CartResponse.fromJson(data);
    } else {
      throw Exception("Lỗi server: ${response.statusCode}");
    }
  }
}
