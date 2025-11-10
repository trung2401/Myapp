import 'package:flutter/material.dart';
import '../model/order.dart';
import '../services/api_list_order_service.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
    with SingleTickerProviderStateMixin {
  final String baseUrl = "https://res.cloudinary.com/doy1zwhge/image/upload";
  late TabController _tabController;
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  final List<String> _tabs = [
    "ALL",
    "PENDING",
    "DELIVERING",
    "COMPLETED",
    "CANCELLED",
    "RETURNED"
  ];

  final List<String> _tabTitles = [
    "Tất cả",
    "Đang xử lý",
    "Đang giao",
    "Hoàn tất",
    "Đã hủy",
    "Trả hàng"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchOrders(_tabs[_tabController.index]);
      }
    });
    _fetchOrders("ALL");
  }

  Future<void> _fetchOrders(String status) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // ⚙️ chuẩn hóa status cho backend (ví dụ backend dùng chữ thường)
      final apiStatus = status == "ALL" ? "ALL" : status.toUpperCase();

      final orders = await ApiListOrderService.getOrders(apiStatus);
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // ✅ Căn giữa tiêu đề
        title: const Text(
          "Đơn hàng của tôi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft, // ✅ ép TabBar sát mép trái
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.redAccent,
              unselectedLabelColor: Colors.black87,
              indicatorColor: Colors.redAccent,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12), // ✅ thu hẹp padding giữa các tab
              tabs: _tabTitles.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ),

      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _orders.isEmpty
          ? const Center(child: Text("Không có đơn hàng nào"))
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            color: Colors.white, // ✅ Nền trắng cho Card
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // ✅ Bo góc card 15px
            ),
            elevation: 3, // ✅ đổ bóng nhẹ cho đẹp
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "#${order.id} • ${order.status}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ngày đặt: ${order.createdAt.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Divider(),

                  // ✅ Hiển thị danh sách sản phẩm trong đơn hàng
                  for (var item in order.items)
                    ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5), // ✅ bo góc ảnh 5px
                          border: Border.all(
                            color: Colors.grey.shade300, // ✅ viền màu xám nhạt
                            width: 0.5, // ✅ viền 1px
                          ),
                        ),
                        clipBehavior: Clip.hardEdge, // ✅ giúp ảnh không tràn viền
                        child: Image.network(
                          "$baseUrl${item.thumbnail}",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text("Số lượng: ${item.quantity}"),
                      trailing: Text(
                        "${item.specialPrice.toStringAsFixed(0)} ₫",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const Divider(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Thành tiền: ${order.totalAmount.toStringAsFixed(0)} ₫",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
