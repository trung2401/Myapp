import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_get_review_service.dart';

void showReviewSheet(BuildContext context, int productId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => ReviewBottomSheet(productId: productId),
  );
}

class ReviewBottomSheet extends StatefulWidget {
  final int productId;

  const ReviewBottomSheet({super.key, required this.productId});

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  int overallRating = 0;
  int performance = 5;
  int battery = 5;
  int camera = 5;

  final contentCtrl = TextEditingController();
  final picker = ImagePicker();
  List<File> images = [];
  bool loading = false;

  Future pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        images.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Widget starSelector(int selected, Function(int) onChanged) {
    return Row(
      children: List.generate(5, (i) {
        final index = i + 1;
        return IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => onChanged(index),
          icon: Icon(
            index <= selected ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }

  Future submit() async {
    print("=== Submit Review ===");
    print("Overall rating: $overallRating");
    print("Review content: ${contentCtrl.text.trim()}");
    print("Number of images: ${images.length}");
    for (var i = 0; i < images.length; i++) {
      print("Image $i path: ${images[i].path}");
    }

    if (overallRating == 0) {
      print("❌ Chưa chọn sao");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn số sao")),
      );
      return;
    }
    if (contentCtrl.text.trim().length < 15) {
      print("❌ Nội dung quá ngắn");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập nội dung tối thiểu 15 ký tự")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      print("⏳ Đang gửi review...");
      await GetReviewService().postReview(
        productId: widget.productId,
        rating: overallRating,
        content: contentCtrl.text.trim(),
        medias: images,
      );

      if (mounted) {
        print("✔ Gửi review thành công!");
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✔ Gửi đánh giá thành công!")),
        );
      }
    } catch (e) {
      print("❌ Lỗi gửi review: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi gửi đánh giá: $e")),
      );
    }

    setState(() => loading = false);
    print("=== End Submit ===");
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(50),
            ),
          ),

          const Text(
            "Đánh giá & nhận xét",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Đánh giá chung",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),

          starSelector(overallRating, (v) => setState(() => overallRating = v)),

          // const Divider(height: 32),
          //
          // const Align(
          //   alignment: Alignment.centerLeft,
          //   child: Text("Theo trải nghiệm",
          //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          // ),
          //
          // _buildExperienceRow("Hiệu năng", "Siêu mạnh mẽ", performance,
          //         (v) => setState(() => performance = v)),
          // _buildExperienceRow("Thời lượng pin", "Cực khủng", battery,
          //         (v) => setState(() => battery = v)),
          // _buildExperienceRow("Chất lượng camera", "Chụp đẹp, chuyên nghiệp",
          //     camera, (v) => setState(() => camera = v)),

          const SizedBox(height: 16),

          TextField(
            controller: contentCtrl,
            minLines: 4,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
              "Xin mời chia sẻ một số cảm nhận (tối thiểu 15 ký tự)",
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              InkWell(
                onTap: pickImages,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.photo_library, size: 28),
                      SizedBox(height: 4),
                      Text("Thêm hình ảnh",
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: images
                        .map(
                          (img) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(img,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover),
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 20),

          // --- Button ---
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: loading ? null : submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("GỬI ĐÁNH GIÁ",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget _buildExperienceRow(String label, String caption,
  //     int stars, Function(int) onChanged) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6),
  //     child: Row(
  //       children: [
  //         SizedBox(width: 110, child: Text(label)),
  //         starSelector(stars, onChanged),
  //         Expanded(child: Text(caption, textAlign: TextAlign.right)),
  //       ],
  //     ),
  //   );
  // }
}
