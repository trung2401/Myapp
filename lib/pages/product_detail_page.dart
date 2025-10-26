import 'package:flutter/material.dart';
import 'package:myapp/model/product_detail.dart';
import 'package:myapp/services/api_product_detail_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/services/api_add_cart_service.dart';
import 'package:myapp/model/add_cart_response.dart';

import 'login_page.dart';


class ProductDetailPage extends StatefulWidget {
  final String productSlug;

  const ProductDetailPage({super.key, required this.productSlug});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<ProductDetail> _futureProduct;
  late Future<bool> _isLoggedIn;
  int selectedColorIndex = 0;
  int currentSlide = 0;
  final String baseUrl = "https://res.cloudinary.com/doy1zwhge/image/upload";

  @override
  void initState() {
    super.initState();
    _isLoggedIn = _checkLoginStatus();

    _futureProduct = ProductApiService().fetchProductDetail(widget.productSlug);
  }
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin sản phẩm",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: const [
          Icon(Icons.share_outlined),
          SizedBox(width: 10),
          Icon(Icons.shopping_cart_outlined),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: FutureBuilder<ProductDetail>(
          future: _futureProduct,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Lỗi tải dữ liệu: ${snapshot.error}"));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("Không có dữ liệu"));
            }

            final product = snapshot.data!;

            // 🔹 Slide đầu: ảnh + mô tả nổi bật | Các slide sau: chỉ ảnh variant
            final slides = [
              {
                "image": product.thumbnail.isNotEmpty
                    ? "$baseUrl${product.thumbnail}"
                    : "",
                "desc":
                "• Màn hình:${product.detail.screenTechnology}\n"
                    "• Camera: Sau ${product.detail.cameraRear}"
                    ,
              },
              ...product.variants.map((variant) => {
                "image": variant.thumbnail.isNotEmpty
                    ? "$baseUrl${variant.thumbnail}"
                    : "",
              }),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 SLIDE DYNAMIC
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: PageView.builder(
                    onPageChanged: (index) => setState(() => currentSlide = index),
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      final slide = slides[index];

                      // 🔸 Slide đầu có mô tả
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: slide["image"]!.isNotEmpty
                                    ? Image.network(slide["image"]!,
                                    fit: BoxFit.contain)
                                    : const Icon(Icons.broken_image, size: 50),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "TÍNH NĂNG NỔI BẬT",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        slide["desc"] ?? '',
                                        style: const TextStyle(
                                            fontSize: 13, height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // 🔸 Các slide sau chỉ hiển thị ảnh variant
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: slide["image"]!.isNotEmpty
                                ? Image.network(
                              slide["image"]!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 50),
                            )
                                : const Icon(Icons.image_not_supported, size: 60),
                          ),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // 🔸 Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.all(4),
                      width: currentSlide == index ? 10 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: currentSlide == index
                            ? Colors.red
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 🔹 PRODUCT INFO + Variants
                Text(
                  product.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    SizedBox(width: 4),
                    Text("4.9", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    Icon(Icons.favorite_border, size: 20, color: Colors.blue),
                    SizedBox(width: 4),
                    Text("Yêu thích", style: TextStyle(color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 10),

                // 🔹 Variants Grid
                const Text("Màu sắc",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: product.variants.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 3.8,
                  ),
                  itemBuilder: (context, index) {
                    final variant = product.variants[index];
                    return GestureDetector(
                      onTap: () => setState(() => selectedColorIndex = index),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedColorIndex == index
                                ? Colors.red
                                : Colors.grey.shade400,
                            width: selectedColorIndex == index ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          children: [
                            if (variant.thumbnail.isNotEmpty)
                              Image.network(
                                "$baseUrl${variant.thumbnail}",
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var attr in variant.attributes)
                                    Text(
                                      "${attr.value}",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 🔹 Thông số kỹ thuật
                const Text(
                  "Thông số kỹ thuật",
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      _buildSpecRow(
                          "Kích thước màn hình", product.detail.displaySize),
                      _buildSpecRow("Công nghệ màn hình",
                          product.detail.screenTechnology),
                      _buildSpecRow("Camera sau", product.detail.cameraRear),
                      _buildSpecRow("Camera trước", product.detail.cameraFront),
                      _buildSpecRow("Chipset", product.detail.chipset),
                      _buildSpecRow("Công nghệ NFC", product.detail.nfc),
                      _buildSpecRow("Bộ nhớ trong", product.detail.storage),
                      _buildSpecRow("Thẻ SIM", product.detail.sim),
                      _buildSpecRow("Hệ điều hành", product.detail.osVersion),
                      _buildSpecRow("Độ phân giải màn hình",
                          product.detail.displayResolution),
                      _buildSpecRow(
                          "Tính năng màn hình", product.detail.displayFeatures),
                      _buildSpecRow("Loại CPU", product.detail.cpuType),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // 🔹 Thanh giá + nút hành động
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.phone_in_talk, color: Colors.red),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    var token = prefs.getString('jwtToken');

                    if (token == null || token.isEmpty) {
                      // Nếu chưa đăng nhập, chuyển sang LoginPage
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );

                      // Nếu đăng nhập thành công → đọc lại token
                      if (result == true) {
                        final prefsAfterLogin = await SharedPreferences.getInstance();
                        token = prefsAfterLogin.getString('jwtToken');
                      } else {
                        return; // Nếu thoát ra thì không làm gì
                      }
                    }

                    // Nếu token có rồi → thêm giỏ hàng
                    if (token != null && token.isNotEmpty) {
                      final product = await _futureProduct;
                      final selectedVariant = product.variants[selectedColorIndex];
                      final api = AddCartApiService();
                      final result = await api.addToCart(selectedVariant.id, 1);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result.message.isNotEmpty ? result.message : "Thêm sản phẩm thành công!",)),
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

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text(
                  "Thêm vào giỏ hàng",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  "Mua ngay",
                  style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
