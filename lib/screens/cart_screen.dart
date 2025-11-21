import 'package:flutter/material.dart';
import '../model/cart.dart';
import '../services/api_add_cart_service.dart';
import '../services/api_get_cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CheckoutScreen.dart';

class CartScreen extends StatefulWidget {
  final int? highlightCartItemId; // id sản phẩm vừa mua ngay

  const CartScreen({super.key, this.highlightCartItemId});


  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  List<CartItem> cartItems = [];
  bool isLoading = true;
  final String baseUrl = "https://res.cloudinary.com/doy1zwhge/image/upload";

  // Map lưu trạng thái tick của từng item
  Map<int, bool> selectedItems = {};

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');
      if (token == null || token.isEmpty){
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Người dùng chưa đăng nhập")),
        );
        return;
      }
      final response = await _cartService.getCart();
      setState(() {
        cartItems = response.data.reversed.toList();
        isLoading = false;

        if (widget.highlightCartItemId != null) {
          // tick chỉ item có id = highlightCartItemId
          for (var item in cartItems) {
            selectedItems[item.id] = (item.id == widget.highlightCartItemId);
          }
        } else {
          // tick tất cả item khi load bình thường
          for (var item in cartItems) {
            selectedItems[item.id] = true;
          }
        }

        // Nếu muốn luôn tick item đầu tiên của giao diện
        if (widget.highlightCartItemId != null && cartItems.isNotEmpty) {
          selectedItems[cartItems.first.id] = true;
        }
      });

    } catch (e) {
      print("Lỗi tải giỏ hàng: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tải giỏ hàng: $e")),
      );
    }
  }

  void deleteCartItem(int cartId) async {
    try {
      final response = await _cartService.deleteCartItem(cartId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response ?? "Đã xoá sản phẩm khỏi giỏ")),
      );
      loadCart(); // Tải lại giỏ hàng sau khi xoá
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi xoá sản phẩm: $e")),
      );
    }
  }

  void increaseQuantity(CartItem item) async {
    if (item.quantity < item.item.availableStock) {
      setState(() {
        item.quantity++;
      });

      try {
        final api = AddCartApiService();
        await api.addToCart(item.item.id, item.quantity); // gọi API cập nhật
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi tăng số lượng: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vượt quá số lượng tồn kho'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void decreaseQuantity(CartItem item) async {
    if (item.quantity > 0) {
      setState(() {
        item.quantity--;
      });

      try {
        final api = AddCartApiService();
        await api.addToCart(item.item.id, item.quantity); // gọi API cập nhật
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi giảm số lượng: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vượt quá số lượng tồn kho'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // chỉ tính tổng các item được tick
  double getTotal() {
    double total = 0;
    for (var item in cartItems) {
      if (selectedItems[item.id] ?? false) {
        total += item.item.price * item.quantity;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cart = cartItems[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        // Thêm Checkbox
                        Checkbox(
                          value: selectedItems[cart.id] ?? false,
                          activeColor: Colors.redAccent,
                          onChanged: (value) {
                            setState(() {
                              selectedItems[cart.id] = value ?? false;
                            });
                          },
                        ),
                        if (cart.item.thumbnail.isNotEmpty)
                          Image.network(
                            "$baseUrl${cart.item.thumbnail}",
                            height: 60,
                            width: 60,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cart.item.sku,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "\$${cart.item.price.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => decreaseQuantity(cart),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(cart.quantity.toString()),
                            IconButton(
                              onPressed: () => increaseQuantity(cart),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteCartItem(cart.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("\$${getTotal().toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    final checkoutItems = cartItems
                        .where((item) => selectedItems[item.id] ?? false)
                        .toList();
                    if (checkoutItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng chọn ít nhất một sản phẩm để thanh toán'),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(checkoutItems: checkoutItems),
                        ),
                      );
                    }
                  },

                  child: const Text(
                    "Check Out",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

