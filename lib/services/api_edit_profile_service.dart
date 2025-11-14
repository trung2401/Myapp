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

  // ==========================
  // 🔐 CHANGE PASSWORD
  // ==========================
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwtToken");

    if (token == null) {
      throw Exception("Bạn chưa đăng nhập!");
    }

    final url = Uri.parse("$baseUrl/api/customer/change-password");
    print("🔄 Gửi yêu cầu đổi mật khẩu đến: $url");

    final body = {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    };

    print("📤 Body gửi đi: $body");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("📥 Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Lỗi đổi mật khẩu: ${response.body}");
    }
  }


}
