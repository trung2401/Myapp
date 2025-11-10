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

  // 🗑️ Xoá sản phẩm trong giỏ hàng theo cartId
  Future<String> deleteCartItem(int cartId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null || token.isEmpty) {
      throw Exception("Người dùng chưa đăng nhập");
    }

    final url = Uri.parse("$baseUrl/api/cart/delete-item/$cartId");
    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["message"] ?? "Xoá sản phẩm thành công";
    } else if (response.statusCode == 404) {
      throw Exception("Không tìm thấy sản phẩm trong giỏ hàng");
    } else {
      throw Exception("Lỗi xoá sản phẩm: ${response.statusCode}");
    }
  }

}
