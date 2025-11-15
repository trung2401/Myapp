import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:myapp/model/review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class GetReviewService {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<List<Review>> fetchReviews({
    required int productId,
    int? rating,
    int page = 1,
    int size = 10,
  }) async {
    final url = Uri.parse(
      "$baseUrl/api/public/product/review?size=$size&page=$page&productId=$productId${rating != null ? "&rating=$rating" : ""}",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List items = body['data']['items'];
      return items.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception("Không thể tải đánh giá (${response.statusCode})");
    }
  }

  /// ⭐ POST REVIEW (THÊM ĐÁNH GIÁ)
  /// ==========================
  Future<bool> postReview({
    required int productId,
    required int rating,
    required String content,
    required List<File> medias,
  }) async {
    // Lấy token từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null || token.isEmpty) {
      throw Exception("Người dùng chưa đăng nhập");
    }

    try {
      final url = Uri.parse("$baseUrl/api/interaction/review/$productId");
      final request = http.MultipartRequest("POST", url);

      // Thêm header Authorization
      request.headers['Authorization'] = 'Bearer $token';

      // Thêm fields
      request.fields["rating"] = rating.toString();
      request.fields["content"] = content;

      // Thêm danh sách hình ảnh
      for (var img in medias) {
        request.files.add(
          await http.MultipartFile.fromPath("medias", img.path),
        );
      }

      // Gửi request
      final response = await request.send();
      final respBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          "POST review thất bại (${response.statusCode}): $respBody",
        );
      }
    } catch (e) {
      rethrow;
    }
  }

}
