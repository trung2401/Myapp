import 'package:flutter/material.dart';
import 'package:myapp/screens/payment_qr_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/cart.dart';
import '../model/store.dart';
import '../model/user_profile.dart';
import '../services/api_checkout_pickup_service.dart';
import '../services/api_checkout_ship_service.dart';
import '../services/api_get_profile_service.dart';
import '../services/api_store_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> checkoutItems;

  const CheckoutScreen({super.key, required this.checkoutItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isPickup = true;
  List<Store> stores = [];
  Store? selectedStore;
  bool isLoadingStores = false;
  UserProfile? userProfile;
  UserAddress? defaultAddress;
  bool isLoadingProfile = false;
  final String baseUrl = "https://res.cloudinary.com/doy1zwhge/image/upload";

  @override
  void initState() {
    super.initState();
    fetchStores();
    fetchUserProfile();
  }

  Future<void> fetchStores() async {
    setState(() => isLoadingStores = true);
    try {
      final api = ApiStoreService();
      stores = await api.fetchStores();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tải danh sách cửa hàng: $e")),
      );
    } finally {
      setState(() => isLoadingStores = false);
    }
  }

  Future<void> fetchUserProfile() async {
    setState(() => isLoadingProfile = true);
    try {
      final service = GetProfileService();
      userProfile = await service.getProfile();

      // Lấy địa chỉ mặc định
      final addresses = await service.getAddresses();

      UserAddress? defaultAddr;

      // Tìm địa chỉ mặc định
      for (var addr in addresses) {
        if (addr.isDefault) {
          defaultAddr = addr;
          break;
        }
      }

      // Nếu không có địa chỉ mặc định, lấy phần tử đầu tiên nếu có
      defaultAddress = defaultAddr ?? (addresses.isNotEmpty ? addresses.first : null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải thông tin người dùng: $e')),
      );
    } finally {
      setState(() => isLoadingProfile = false);
    }
  }


  double get totalPrice {
    double total = 0;
    for (var item in widget.checkoutItems) {
      total += item.item.price * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin đơn hàng"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// --- Nội dung cuộn ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sản phẩm thanh toán",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Danh sách sản phẩm được tick
                  ...widget.checkoutItems.map((item) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Image.network(
                          "$baseUrl${item.item.thumbnail}",
                          height: 50,
                          width: 50,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                        ),
                        title: Text(item.item.sku),
                        subtitle: Text(
                          "Số lượng: ${item.quantity} | ${item.item.price.toStringAsFixed(0)}đ",
                        ),
                        trailing: Text(
                          "${(item.item.price * item.quantity).toStringAsFixed(0)}đ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 20),

                  const Text(
                    "Hình thức nhận hàng",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text("Nhận tại cửa hàng"),
                          value: true,
                          groupValue: isPickup,
                          onChanged: (val) => setState(() => isPickup = val!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text("Giao hàng tận nơi"),
                          value: false,
                          activeColor: Colors.redAccent,
                          groupValue: isPickup,
                          onChanged: (val) => setState(() => isPickup = val!),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  if (isPickup) ...[
                    const Text(
                      "Chọn cửa hàng",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    isLoadingStores
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<Store>(
                      value: selectedStore,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Chọn cửa hàng nhận",
                      ),
                      items: stores.map((store) {
                        return DropdownMenuItem<Store>(
                          value: store,
                          child: Container(
                            // padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Text(
                              store.displayAddress ?? "",
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (store) {
                        setState(() {
                          selectedStore = store;
                        });
                      },
                    ),
                  ] else ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row chứa tên + số điện thoại
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Họ và tên: ${userProfile?.name ?? ''}",
                              style: const TextStyle(fontSize: 16,),
                            ),
                            Text(
                              "Số điện thoại: ${userProfile?.phone ?? ''}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Địa chỉ mặc định
                        if (defaultAddress != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.home_outlined, color: Colors.blueGrey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        defaultAddress!.line.isNotEmpty
                                            ? defaultAddress!.line
                                            : 'Địa chỉ không xác định',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    if (defaultAddress!.isDefault)
                                      Container(
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'MẶC ĐỊNH',
                                          style: TextStyle(fontSize: 12, color: Colors.red),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    // 🔹 Nút Edit (tùy nếu bạn có trang EditAddressPage)
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                      onPressed: () async {
                                        // Ví dụ mở trang sửa địa chỉ
                                        // final result = await Navigator.push(...);
                                        // if (result != null && mounted) { setState(...); }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${defaultAddress!.ward}, ${defaultAddress!.district}, ${defaultAddress!.province}",
                                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                          )
                        else
                          const Text(
                            "Chưa có địa chỉ nào",
                            style: TextStyle(fontSize: 16),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          /// --- Phần cố định cuối màn hình ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tổng tiền:",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${totalPrice.toStringAsFixed(0)}đ",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () async {
                    try {
                      // Chuẩn bị danh sách sản phẩm
                      final orderItems = widget.checkoutItems.map((e) => {
                        "variantId": e.item.id,
                        "quantity": e.quantity,
                      }).toList();

                      if (isPickup) {
                        // Kiểm tra cửa hàng
                        if (selectedStore == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Vui lòng chọn cửa hàng nhận")),
                          );
                          return;
                        }

                        // Nhận tại cửa hàng
                        final result = await ApiCheckoutPickupService.createPickupOrder(
                          orderItems: orderItems,
                          fullName: userProfile?.name ?? "",
                          phone: userProfile?.phone ?? "",
                          email: userProfile?.email ?? "",
                          paymentMethod: "cod", // hoặc "cod"
                          storeId: selectedStore!.id,
                        );

                        final data = result['data'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentQrScreen(
                              orderId: data['orderId'].toString(),
                              amount: (data['amount'] ?? 0) * 1.0,
                              paymentInfo: data['paymentInfo'] ?? {},
                            ),
                          ),
                        );
                      } else {
                        // Kiểm tra địa chỉ
                        if (defaultAddress == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Vui lòng chọn địa chỉ giao hàng")),
                          );
                          return;
                        }

                        // Giao hàng tận nơi
                        final result = await ApiCheckoutShipService.createShipOrder(
                          orderItems: orderItems,
                          fullName: userProfile?.name ?? "",
                          phone: userProfile?.phone ?? "",
                          email: userProfile?.email ?? "",
                          paymentMethod: "cod", // hoặc "cod"
                          line: defaultAddress?.line ?? "",
                          ward: defaultAddress?.ward ?? "",
                          district: defaultAddress?.district ?? "",
                          province: defaultAddress?.province ?? "",
                        );

                        final data = result['data'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentQrScreen(
                              orderId: data['orderId'].toString(),
                              amount: (data['amount'] ?? 0) * 1.0,
                              paymentInfo: data['paymentInfo'] ?? {},
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lỗi khi tạo đơn hàng: $e")),
                      );
                      print("Lỗi khi tạo đơn hàng: $e");
                    }
                  },


                  child: const Text(
                    "Xác nhận đặt hàng",
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
