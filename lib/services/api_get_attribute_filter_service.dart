import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/attribute_filter.dart';
import 'api_config.dart';

class AttributeFilterApiService {
  static final String baseUrl = ApiConfig.baseUrl;

  static Future<List<AttributeFilter>> fetchFiltersBySlug(String slug) async {
    final url = Uri.parse('$baseUrl/api/public/attribute/filter/$slug');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['code'] == 1000 && jsonData['data'] != null) {
        final List list = jsonData['data'];
        return list.map((e) => AttributeFilter.fromJson(e)).toList();
      } else {
        throw Exception('API error: ${jsonData['code']}');
      }
    } else {
      throw Exception('Failed to load attribute filters');
    }
  }
}

