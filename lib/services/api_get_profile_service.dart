import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_profile.dart';
import 'api_config.dart';

class GetProfileService {
  final String baseUrl = ApiConfig.baseUrl;

  /// 🔹 Lấy thông tin hồ sơ người dùng
  Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('Chưa đăng nhập hoặc token không tồn tại');
    }

    final url = Uri.parse('$baseUrl/api/customer/my-profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserProfile.fromJson(jsonData['data']);
    } else {
      throw Exception(
          'Lỗi khi tải thông tin người dùng: ${response.statusCode} - ${response.body}');
    }
  }

  /// 🔹 Lấy danh sách địa chỉ của người dùng
  Future<List<UserAddress>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) throw Exception('Chưa đăng nhập');

    final url = Uri.parse('$baseUrl/api/customer/my-profile');
    // ⚠️ vì backend trả địa chỉ nằm trong `my-profile`,
    // không có endpoint riêng `my-addresses`

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final addressesData = jsonData['data']?['addresses'];

      if (addressesData is List) {
        return addressesData.map((e) => UserAddress.fromJson(e)).toList();
      } else {
        throw Exception('Không có danh sách địa chỉ trong phản hồi');
      }
    } else {
      throw Exception(
          'Lỗi tải danh sách địa chỉ: ${response.statusCode} - ${response.body}');
    }
  }
}
