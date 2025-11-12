import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiCheckoutPickupService {
  static const String baseUrl = ApiConfig.baseUrl;
  /// 🛍️ Tạo đơn hàng nhận tại cửa hàng
  static Future<Map<String, dynamic>> createPickupOrder({
    required List<Map<String, dynamic>> orderItems,
    required String fullName,
    required String phone,
    required String email,
    required String paymentMethod,
    required int storeId,
  }) async {
    // ✅ Lấy token từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    // ✅ Kiểm tra token có hợp lệ không
    if (token == null || token.isEmpty) {
      throw Exception("Người dùng chưa đăng nhập hoặc token không hợp lệ");
    }

    final url = Uri.parse("$baseUrl/api/checkout/pickup");

    final body = {
      "orderItems": orderItems,
      "fullName": fullName,
      "phone": phone,
      "email": email,
      "paymentMethod": paymentMethod,
      "storeId": storeId,
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
      return data; // ✅ Trả về thông tin đơn hàng (orderId, amount, v.v.)
    } else {
      final errorMessage = response.body.isNotEmpty
          ? jsonDecode(response.body)['message'] ?? "Lỗi không xác định"
          : "Không nhận được phản hồi từ máy chủ";
      throw Exception(
          "Tạo đơn hàng thất bại (${response.statusCode}): $errorMessage");
    }
  }
}
