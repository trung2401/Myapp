import 'package:flutter/material.dart';
import 'package:myapp/model/product_detail.dart';
import 'package:myapp/widgets/review_buttom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/login_page.dart';

class RatingSummaryWidget extends StatelessWidget {
  final ProductDetail product;

  const RatingSummaryWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final total = product.rating.total == 0 ? 1 : product.rating.total; // tránh chia 0

    Widget _buildRatingBar(int stars, int count) {
      final percent = count / total;
      return Row(
        children: [
          Text('$stars ★', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percent,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('$count đánh giá', style: const TextStyle(fontSize: 13)),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Điểm trung bình + nút viết đánh giá
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    product.rating.average.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const Text(
                    "/5",
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.orange),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  try{
                    final prefs = await SharedPreferences.getInstance();
                    var token = prefs.getString('jwtToken');

                    if (token == null || token.isEmpty) {
                      // Nếu chưa đăng nhập, chuyển sang LoginPage
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage(fromDetail: true)),
                      );

                      // Nếu đăng nhập thành công → đọc lại token
                      if (result == true) {
                        final prefsAfterLogin = await SharedPreferences.getInstance();
                        token = prefsAfterLogin.getString('jwtToken');
                      } else {
                        return; // Nếu thoát ra thì không làm gì
                      }
                    }
                    if (token != null && token.isNotEmpty) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) => ReviewBottomSheet(productId: product.id),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Không thể xác thực người dùng")),
                      );
                    }

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi khi thêm giỏ hàng: $e")),
                    );
                  }

                },

                child: const Text("Viết đánh giá",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            "${product.rating.total} lượt đánh giá",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 10),

          // Thanh sao
          _buildRatingBar(5, product.rating.star5),
          const SizedBox(height: 4),
          _buildRatingBar(4, product.rating.star4),
          const SizedBox(height: 4),
          _buildRatingBar(3, product.rating.star3),
          const SizedBox(height: 4),
          _buildRatingBar(2, product.rating.star2),
          const SizedBox(height: 4),
          _buildRatingBar(1, product.rating.star1),
        ],
      ),
    );
  }
}
