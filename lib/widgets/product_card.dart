import 'package:flutter/material.dart';
import '../model/product.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white, // nền trắng
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 4), // bóng đổ xuống
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hình + icon yêu thích
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  widget.product.image,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16,
                  child: Icon(
                    Icons.favorite_border_outlined,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          // Tên + Category + Giá
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // const SizedBox(height: 4),
                // Text(
                //   widget.product.category,
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: Colors.grey[600],
                //   ),
                // ),
                const SizedBox(height: 6),
                Text(
                  "\$${widget.product.price}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
