import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_profile.dart';
import 'api_config.dart';

class EditProfileService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<UserProfile> updateProfile({
    required String name,
    required String gender,
    required String birth,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('Chưa đăng nhập hoặc token không tồn tại');
    }

    final url = Uri.parse('$baseUrl/api/customer/my-profile');
    final body = jsonEncode({
      "name": name,
      "gender": gender,
      "birth": birth,
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
      final jsonData = jsonDecode(response.body);
      return UserProfile.fromJson(jsonData['data']);
    } else {
      print('❌ Response body: ${response.body}');
      throw Exception('Lỗi khi cập nhật hồ sơ: ${response.statusCode}');
    }
  }
}
