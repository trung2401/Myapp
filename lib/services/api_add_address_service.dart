import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_profile.dart'; // dùng lại UserAddress model

class AddAddressService {
  final String baseUrl = ApiConfig.baseUrl; // 🔹 đổi lại domain thật của bạn

  Future<UserAddress> addAddress({
    required String line,
    required String ward,
    required String district,
    required String province,
    required bool isDefault,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('Chưa đăng nhập hoặc token hết hạn');
    }

    final url = Uri.parse('$baseUrl/api/customer/my-address'); // 🔹 endpoint backend bạn dùng
    final body = jsonEncode({
      "line": line,
      "ward": ward,
      "district": district,
      "province": province,
      "isDefault": isDefault,
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserAddress.fromJson(data['data']);
    } else {
      throw Exception('Lỗi thêm địa chỉ: ${response.statusCode} - ${response.body}');
    }
  }
}
