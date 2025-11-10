import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/order.dart';
import 'api_config.dart';

class ApiListOrderService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// 🔹 Lấy danh sách đơn hàng (lọc theo trạng thái nếu có)
  static Future<List<Order>> getOrders(
      String orderStatus, {
        int page = 1,
        int size = 10,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('⚠️ Chưa đăng nhập hoặc token không tồn tại');
    }

    // ✅ Nếu là "ALL" thì không truyền orderStatus vào query
    final statusQuery =
    orderStatus == "ALL" ? "" : "&orderStatus=$orderStatus";

    // ✅ Đúng theo format backend yêu cầu
    final url =
    Uri.parse("$baseUrl/api/customer/my-order?size=$size&page=$page$statusQuery");

    print("🔹 Fetching from: $url"); // debug log

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse["data"] != null &&
          jsonResponse["data"]["items"] != null) {
        final List<dynamic> items = jsonResponse["data"]["items"];
        return items.map((e) => Order.fromJson(e)).toList();
      } else {
        throw Exception("⚠️ Phản hồi API không hợp lệ: thiếu data/items");
      }
    } else {
      throw Exception(
          "❌ Lỗi tải danh sách đơn hàng: ${response.statusCode} - ${response.body}");
    }
  }
}
