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
}
