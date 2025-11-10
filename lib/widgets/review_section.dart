import 'package:flutter/material.dart';
import 'package:myapp/model/review.dart';
import 'package:myapp/services/api_get_review_service.dart';

class ReviewSection extends StatefulWidget {
  final int productId;
  const ReviewSection({super.key, required this.productId});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  int? selectedRating;
  late Future<List<Review>> _futureReviews;
  final baseUrl = "https://res.cloudinary.com/doy1zwhge/image/upload";

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    setState(() {
      _futureReviews = GetReviewService()
          .fetchReviews(productId: widget.productId, rating: selectedRating);
    });
  }

  Widget _buildFilterButton(String text, int? rating) {
    final isSelected = selectedRating == rating;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.red : Colors.white,
        side: BorderSide(color: isSelected ? Colors.red : Colors.grey),
      ),
      onPressed: () {
        setState(() {
          selectedRating = rating;
        });
        _loadReviews();
      },
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Bộ lọc sao
        Wrap(
          spacing: 6,
          children: [
            _buildFilterButton("Tất cả", null),
            for (var i = 5; i >= 1; i--) _buildFilterButton("$i sao", i),
          ],
        ),
        const SizedBox(height: 12),

        // 🔹 Danh sách đánh giá
        FutureBuilder<List<Review>>(
          future: _futureReviews,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text("Lỗi tải đánh giá: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Chưa có đánh giá nào"));
            }

            final reviews = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔸 Tên + số sao
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              child: Text(
                                review.customer.name.isNotEmpty
                                    ? review.customer.name[0].toUpperCase()
                                    : "?",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                review.customer.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                    (i) => Icon(
                                  i < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(review.content),
                        const SizedBox(height: 6),

                        // 🔸 Hình ảnh đánh giá (nếu có)
                        if (review.medias.isNotEmpty)
                          SizedBox(
                            height: 80,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: review.medias.map((media) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      "$baseUrl${media.url}",
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
