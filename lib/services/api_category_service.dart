import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/category.dart';
import 'api_config.dart';

class CategoryApiService {
  final String baseUrl = ApiConfig.baseUrl;

  /// Lấy danh sách category chính (main)
  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse("$baseUrl/api/public/category/main"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData["code"] == 1000) {
        final List<dynamic> data = jsonData["data"];
        return data.map((e) => Category.fromJson(e)).toList();
      } else {
        throw Exception("API error code: ${jsonData["code"]}");
      }
    } else {
      throw Exception("Failed to load categories");
    }
  }

  Future<List<Category>> fetchSubCategories(String slug) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/public/category/$slug?type=brand"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Truy cập children
      List<dynamic> cates = data["data"]["children"];
      return cates.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load categories: ${response.statusCode}");
    }
  }

  Future<List<Category>> fetchFeatureCategories(String slug) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/public/category/$slug?type=feature"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> features = data["data"]["children"];
      return features.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load feature categories: ${response.statusCode}");
    }
  }

  // Hàm get series theo brand

  /// 🔹 Lấy danh sách các dòng series theo brand (VD: /api/public/category/mobile/apple)
  Future<List<Category>> fetchSeriesByBrand(String slug) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/public/category/$slug"), // ❌ Không có ?type=brand
    );

    print("📡 Gọi API series: $baseUrl/api/public/category/$slug");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Truy cập children (các series)
      List<dynamic> seriesList = data["data"]["children"];
      return seriesList.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load series by brand: ${response.statusCode}");
    }
  }



}
