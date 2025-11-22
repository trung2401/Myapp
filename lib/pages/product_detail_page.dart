import 'package:flutter/material.dart';
import 'package:myapp/model/product_detail.dart';
import 'package:myapp/services/api_product_detail_service.dart';
import 'package:myapp/widgets/store_card_row.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/services/api_add_cart_service.dart';
import 'package:myapp/model/add_cart_response.dart';

import '../screens/cart_screen.dart';
import '../services/api_get_favorite_service.dart';
import '../widgets/rating_summary_widget.dart';
import '../widgets/review_section.dart';
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
  bool isFavorite = false;


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
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
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
              final variant = product.variants.isNotEmpty ? product.variants.first : null;
              final selectedVariant = product.variants[selectedColorIndex];
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
                      border: Border.all(color: Colors.grey.shade400),

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

                  // 🔹 Giá sản phẩm
                  if (selectedVariant.specialPrice > 0) ...[
                    Row(
                      children: [
                        Text(
                          "${selectedVariant.specialPrice.toStringAsFixed(0)}₫",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${selectedVariant.price.toStringAsFixed(0)}₫",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      "${selectedVariant.price.toStringAsFixed(0)}₫",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                          product.rating.average.toStringAsFixed(1)
                          , style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('jwtToken');

                            if (token == null || token.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Vui lòng đăng nhập để yêu thích sản phẩm")),
                              );
                              return;
                            }

                            final product = await _futureProduct;

                            setState(() {
                              isFavorite = !isFavorite; // toggle ngay trên UI
                            });

                            // 🔹 Gọi API theo trạng thái mới
                            if (isFavorite) {
                              await GetFavoriteService.likeProduct(product.id);
                            } else {
                              await GetFavoriteService.unlikeProduct(product.id);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Lỗi: $e")),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Yêu thích",
                              style: TextStyle(
                                color: isFavorite ? Colors.red : Colors.blue,
                                fontWeight: isFavorite ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),


                    ],
                  ),
                  const SizedBox(height: 10),
                  // 🔹 SIBLINGS GRID
                  if (product.siblings.isNotEmpty) ...[
                    const Text(
                      "Sản phẩm liên quan",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: product.siblings.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 3.8,
                      ),
                      itemBuilder: (context, index) {
                        final sibling = product.siblings[index];
                        return GestureDetector(
                          onTap: () {
                            // Chuyển sang ProductDetailPage mới khi chọn sibling
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailPage(productSlug: sibling.slug),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 1.5),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    sibling.name,
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 🔹 Variants Grid
                  // 🔹 Variants Grid
                  const Text("Màu sắc",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: product.variants.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 3.8,
                    ),
                    itemBuilder: (context, index) {
                      final variant = product.variants[index];
                      final bool isOutOfStock = variant.availableStock == 0;
                      final bool isSelected = selectedColorIndex == index;

                      return GestureDetector(
                        onTap: isOutOfStock
                            ? null // ❌ Không cho chọn nếu hết hàng
                            : () {
                          setState(() {
                            selectedColorIndex = index;
                          });
                        },
                        child: Opacity(
                          opacity: isOutOfStock ? 0.4 : 1.0, // 🔹 Làm mờ nếu hết hàng
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.red : Colors.grey.shade400,
                                width: isSelected ? 2 : 1,
                              ),
                              color: Colors.white,
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
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      // // 🔹 Hiển thị giá mỗi variant
                                      // Text(
                                      //   "${variant.specialPrice > 0 ? variant.specialPrice : variant.price}₫",
                                      //   style: TextStyle(
                                      //     color: isOutOfStock ? Colors.grey : Colors.red,
                                      //     fontWeight: FontWeight.bold,
                                      //     fontSize: 13,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  StoreCardRow(),
                  const SizedBox(height: 20),

                  // 🔹 Thông số kỹ thuật
                  // 🔹 Thông số kỹ thuật
                  const Text(
                    "Thông số kỹ thuật",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        if (product.detail.displaySize.isNotEmpty)
                          _buildSpecRow("Kích thước màn hình", product.detail.displaySize),
                        if (product.detail.screenTechnology.isNotEmpty)
                          _buildSpecRow("Công nghệ màn hình", product.detail.screenTechnology),
                        if (product.detail.cameraRear.isNotEmpty)
                          _buildSpecRow("Camera sau", product.detail.cameraRear),
                        if (product.detail.cameraFront.isNotEmpty)
                          _buildSpecRow("Camera trước", product.detail.cameraFront),
                        if (product.detail.chipset.isNotEmpty)
                          _buildSpecRow("Chipset", product.detail.chipset),
                        if (product.detail.nfc.isNotEmpty)
                          _buildSpecRow("Công nghệ NFC", product.detail.nfc),
                        if (product.detail.storage.isNotEmpty)
                          _buildSpecRow("Bộ nhớ trong", product.detail.storage),
                        if (product.detail.sim.isNotEmpty)
                          _buildSpecRow("Thẻ SIM", product.detail.sim),
                        if (product.detail.osVersion.isNotEmpty)
                          _buildSpecRow("Hệ điều hành", product.detail.osVersion),
                        if (product.detail.displayResolution.isNotEmpty)
                          _buildSpecRow("Độ phân giải màn hình", product.detail.displayResolution),
                        if (product.detail.displayFeatures.isNotEmpty)
                          _buildSpecRow("Tính năng màn hình", product.detail.displayFeatures),
                        if (product.detail.cpuType.isNotEmpty)
                          _buildSpecRow("Loại CPU", product.detail.cpuType),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // 🔹 Phần hiển thị đánh giá tổng quan (4.9/5)
                  const Text(
                    "Đánh giá sản phẩm",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  RatingSummaryWidget(product: product),
                  const SizedBox(height: 20),

                  // 🔹 Phần Đánh giá sản phẩm
                  const Text(
                    "Lọc đánh giá theo",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  ReviewSection(productId: product.id),

                ],
              );
            },
          ),
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
                // Thay onPressed của "Mua ngay"
                onPressed: () async {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    var token = prefs.getString('jwtToken');

                    if (token == null || token.isEmpty) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage(fromDetail: true)),
                      );
                      if (result == true) {
                        final prefsAfterLogin = await SharedPreferences.getInstance();
                        token = prefsAfterLogin.getString('jwtToken');
                      } else {
                        return;
                      }
                    }

                    if (token != null && token.isNotEmpty) {
                      final product = await _futureProduct;
                      final selectedVariant = product.variants[selectedColorIndex];

                      // Thêm sản phẩm vào giỏ hàng
                      final api = AddCartApiService();
                      final result = await api.addToCart(selectedVariant.id, 1);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message.isNotEmpty
                              ? result.message
                              : "Thêm sản phẩm thành công!"),
                        ),
                      );

                      // 🔹 Chuyển sang CartScreen, truyền ID sản phẩm vừa thêm
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartScreen(
                            highlightCartItemId: selectedVariant.id,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi khi thêm giỏ hàng: $e")),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  "Mua ngay",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
