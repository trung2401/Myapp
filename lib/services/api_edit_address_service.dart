import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_profile.dart';

class EditAddressService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<UserAddress> updateAddress({
    required int id,
    required String line,
    required String ward,
    required String district,
    required String province,
    required bool isDefault,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('❌ Chưa đăng nhập hoặc token hết hạn');
    }

    // ✅ Không có /id trong URL
    final url = Uri.parse('$baseUrl/api/customer/my-address');

    final body = jsonEncode({
      "id": id, // ✅ id truyền trong body
      "line": line,
      "ward": ward,
      "district": district,
      "province": province,
      "isDefault": isDefault,
    });

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserAddress.fromJson(data['data']);
    } else {
      throw Exception('❌ Lỗi cập nhật địa chỉ: ${response.statusCode} - ${response.body}');
    }
  }
  Future<void> deleteAddress({required int id}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('❌ Chưa đăng nhập hoặc token hết hạn');
    }

    // ✅ id truyền trong URL
    final url = Uri.parse('$baseUrl/api/customer/my-address/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Xoá thành công, không cần return gì
      return;
    } else {
      throw Exception('❌ Xoá địa chỉ thất bại: ${response.statusCode} - ${response.body}');
    }
  }
}
