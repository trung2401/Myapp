import 'package:flutter/material.dart';
import 'package:myapp/model/product_detail.dart';

class RatingSummaryWidget extends StatelessWidget {
  final Rating rating;

  const RatingSummaryWidget({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final total = rating.total == 0 ? 1 : rating.total; // tránh chia 0

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
                    rating.average.toStringAsFixed(1),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tính năng viết đánh giá đang được phát triển.")),
                  );
                },
                child: const Text("Viết đánh giá",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            "${rating.total} lượt đánh giá",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 10),

          // Thanh sao
          _buildRatingBar(5, rating.star5),
          const SizedBox(height: 4),
          _buildRatingBar(4, rating.star4),
          const SizedBox(height: 4),
          _buildRatingBar(3, rating.star3),
          const SizedBox(height: 4),
          _buildRatingBar(2, rating.star2),
          const SizedBox(height: 4),
          _buildRatingBar(1, rating.star1),
        ],
      ),
    );
  }
}
