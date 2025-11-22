import 'package:flutter/material.dart';
import '../model/product.dart';
import '../pages/product_detail_page.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // 🔥 Base URL của backend
  final String baseUrl = "https://res.cloudinary.com/doy1zwhge/image/upload";

  @override
  Widget build(BuildContext context) {
    // Nếu thumbnail không phải link đầy đủ thì ghép base URL
    String imageUrl = widget.product.thumbnail.startsWith('http')
        ? widget.product.thumbnail
        : "$baseUrl${widget.product.thumbnail}";

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailPage(productSlug: widget.product.slug),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade400),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🖼 Ảnh sản phẩm
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 160, // tăng chiều cao để ảnh đầy đủ hơn
                fit: BoxFit.contain, // ✅ hiển thị toàn bộ ảnh, không bị crop
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 160,
                    child: Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),

            // ❤️ Icon yêu thích
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16,
                  child: const Icon(
                    Icons.favorite_border_outlined,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
            ),

            // 📄 Thông tin sản phẩm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm có thể xuống dòng
                  Text(
                    widget.product.name,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2, // ✅ cho phép xuống tối đa 2 dòng
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Giá sản phẩm
                  Text(
                    "${widget.product.price}₫",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
