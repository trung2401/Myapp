import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product_detail.dart';
import 'api_config.dart';

class ProductApiService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<ProductDetail> fetchProductDetail(String slug) async {
    final url = Uri.parse("$baseUrl/api/public/product/$slug/detail");
    final response = await http.get(url);

    print("Response body: ${response.body}"); // in ra để debug

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData["data"] != null) {  // chỉ check data != null
        return ProductDetail.fromJson(jsonData["data"]);
      } else {
        throw Exception("No data in API response: ${jsonData["message"]}");
      }
    } else {
      throw Exception("Failed to load product detail");
    }
  }
}

