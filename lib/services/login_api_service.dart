import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/login_response.dart';
import 'api_config.dart';

class LoginApiService {
  final String baseUrl = ApiConfig.baseUrl;
  Timer? _refreshTimer;

  // ==========================
  // 🔐 LOGIN (giữ nguyên code cũ)
  // ==========================
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
        await prefs.setInt("loginTime", DateTime.now().millisecondsSinceEpoch);

        print("✅ Lưu token & thời điểm đăng nhập thành công");

        // 👉 Khởi động hẹn giờ refresh token
        _scheduleTokenRefresh();
      } else {
        print("⚠️ Không có accessToken trong response");
      }

      return loginResponse;
    } else {
      throw Exception("Lỗi đăng nhập: ${response.statusCode}");
    }
  }

  // ==========================
  // ♻️ REFRESH TOKEN
  // ==========================
  Future<bool> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString("refreshToken");

    if (refreshToken == null) {
      print("⚠️ Không có refreshToken — cần đăng nhập lại");
      return false;
    }

    final url = Uri.parse("$baseUrl/api/public/auth/refresh_token");
    print("♻️ Refresh token tại: $url");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    print("🔹 Response (refresh): ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(data);

      final newAccess = loginResponse.data?.accessToken;
      final newRefresh = loginResponse.data?.refreshToken;

      if (newAccess != null && newRefresh != null) {
        await prefs.setString("jwtToken", newAccess);
        await prefs.setString("refreshToken", newRefresh);
        await prefs.setInt("loginTime", DateTime.now().millisecondsSinceEpoch);
        print("✅ Refresh token thành công (tự động gia hạn)");

        // reset hẹn giờ sau khi refresh
        _scheduleTokenRefresh();
        return true;
      } else {
        print("⚠️ API không trả về accessToken hoặc refreshToken mới");
        return false;
      }
    } else {
      print("❌ Lỗi khi refresh token: ${response.statusCode}");
      return false;
    }
  }

  // ==========================
  // 🕒 HẸN GIỜ REFRESH TOKEN
  // ==========================
  void _scheduleTokenRefresh() async {
    _refreshTimer?.cancel(); // hủy timer cũ nếu có

    // ⚙️ Giả sử access token có hạn 15 phút → refresh sau 14 phút
    const tokenLifetime = Duration(minutes: 2);
    const refreshBeforeExpire = Duration(minutes: 1);

    final refreshDuration = tokenLifetime - refreshBeforeExpire;
    print("🕒 Đặt hẹn giờ refresh token sau ${refreshDuration.inMinutes} phút");

    _refreshTimer = Timer(refreshDuration, () async {
      print("⏰ Đến thời gian refresh token...");
      await refreshAccessToken();
    });
  }

  // ==========================
  // 🔑 LẤY ACCESS TOKEN
  // ==========================
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwtToken");
  }

  // ==========================
  // 🚪 XÓA TOKEN (khi logout)
  // ==========================
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwtToken");
    await prefs.remove("refreshToken");
    await prefs.remove("loginTime");
    _refreshTimer?.cancel();
    print("🚪 Đã xóa token & hủy timer refresh");
  }

  Future<String> resetPassword(String email) async {
    final url = Uri.parse("$baseUrl/api/public/auth/reset-password");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["message"] ?? "Vui lòng kiểm tra email của bạn.";
    } else {
      throw Exception("Yêu cầu thất bại: ${response.body}");
    }
  }

  // ==========================
// 📝 REGISTER USER
// ==========================
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final url = Uri.parse("$baseUrl/api/public/auth/register");
    print("🔸 Gửi đăng ký tới: $url");

    final body = {
      "name": name,
      "email": email,
      "password": password,
      "phone": phone,
    };

    print("📤 Body gửi đi: $body");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("📥 Response: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Lỗi đăng ký: ${response.body}");
    }
  }



}
