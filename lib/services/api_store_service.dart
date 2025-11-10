import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/model/store.dart';
import 'api_config.dart';

class ApiStoreService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Lấy danh sách các cửa hàng
  Future<List<Store>> fetchStores() async {
    final url = Uri.parse('$baseUrl/api/public/store');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List data = body['data'];
      return data.map((e) => Store.fromJson(e)).toList();
    } else {
      throw Exception(
          'Không thể tải danh sách cửa hàng (${response.statusCode})');
    }
  }
}
