import 'package:flutter/material.dart';
import '../model/category.dart';
import '../services/api_category_service.dart';
import '../pages/list_product_page.dart';

class BrandRowWidget extends StatefulWidget {
  final String categorySlug; // ví dụ: "mobile", "laptop"...

  const BrandRowWidget({super.key, required this.categorySlug});

  @override
  State<BrandRowWidget> createState() => _BrandRowWidgetState();
}

class _BrandRowWidgetState extends State<BrandRowWidget> {
  List<Category> brands = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async {
    try {
      // ✅ Gọi API lấy brand theo categorySlug
      final fetched = await CategoryApiService().fetchSubCategories(widget.categorySlug);
      setState(() {
        brands = fetched;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Lỗi khi tải brand: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (brands.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text(
            "Không có thương hiệu nào.",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      );
    }

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: brands.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final brand = brands[index];
          return GestureDetector(
            onTap: () {
              print("🟢 Chọn brand: ${brand.name} - slug: ${brand.slug}");

              // 👉 Chuyển đến trang list sản phẩm theo brand
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListProductPage(category: brand),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(20),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.grey.withOpacity(0.2),
                //     blurRadius: 3,
                //     offset: const Offset(1, 2),
                //   ),
                // ],
              ),
              child: Center(
                child: Text(
                  brand.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
