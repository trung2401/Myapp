import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/model/review.dart';

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
}
