import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiCheckoutShipService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// 🚚 Tạo đơn hàng giao hàng tận nơi
  static Future<Map<String, dynamic>> createShipOrder({
    required List<Map<String, dynamic>> orderItems,
    required String fullName,
    required String phone,
    required String email,
    required String paymentMethod, // "qr" hoặc "cod"
    required String line,
    required String ward,
    required String district,
    required String province,
  }) async {
    // ✅ Lấy token từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    // ✅ Kiểm tra token
    if (token == null || token.isEmpty) {
      throw Exception("Người dùng chưa đăng nhập hoặc token không hợp lệ");
    }

    final url = Uri.parse("$baseUrl/api/checkout/ship");

    final body = {
      "orderItems": orderItems,
      "fullName": fullName,
      "phone": phone,
      "email": email,
      "paymentMethod": paymentMethod,
      "line": line,
      "ward": ward,
      "district": district,
      "province": province,
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final errorMessage = response.body.isNotEmpty
          ? jsonDecode(response.body)['message'] ?? "Lỗi không xác định"
          : "Không nhận được phản hồi từ máy chủ";
      throw Exception(
          "Tạo đơn hàng thất bại (${response.statusCode}): $errorMessage");
    }
  }
}
