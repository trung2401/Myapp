import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/login_response.dart';
import 'api_config.dart';

class LoginApiService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<LoginResponse> login(String phone, String password) async {
    final url = Uri.parse("$baseUrl/api/public/auth/login");
    print("🔸 Base URL đang dùng: $baseUrl");
    print("🔸 Full endpoint: $url");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phone,
        "password": password,
      }),
    );

    print("🔹 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(data);

      if (loginResponse.data?.accessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwtToken", loginResponse.data!.accessToken!);
        await prefs.setString("refreshToken", loginResponse.data!.refreshToken!);
        print("✅ Lưu token thành công: ${loginResponse.data!.accessToken}");
      } else {
        print("⚠️ Không có accessToken trong response");
      }

      return loginResponse;
    } else {
      throw Exception("Lỗi đăng nhập: ${response.statusCode}");
    }
  }
}
