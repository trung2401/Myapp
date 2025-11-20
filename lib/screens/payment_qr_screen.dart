import 'package:flutter/material.dart';

class PaymentQrScreen extends StatelessWidget {
  final String orderId;
  final double amount;
  final Map<String, dynamic> paymentInfo;

  const PaymentQrScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.paymentInfo,
  });

  @override
  Widget build(BuildContext context) {
    final qrUrl = paymentInfo['qrCodeUrl'] ?? '';

    print("🔍 QR URL:");
    print(qrUrl);
    print(paymentInfo);
    print(amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán bằng mã QR"),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Quét mã QR để thanh toán",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              // 👉 HIỂN THỊ ẢNH QR TỪ SEPAY
              Image.network(
                qrUrl,
                width: 220,
                height: 220,
                errorBuilder: (ctx, error, stack) {
                  return const Text("Không tải được QR");
                },
              ),

              const SizedBox(height: 24),

              Text(
                "Mã đơn hàng: $orderId",
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 8),

              Text(
                "Số tiền cần thanh toán: ${amount.toStringAsFixed(0)}đ",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),

              // const SizedBox(height: 32),
              //
              // ElevatedButton.icon(
              //   icon: const Icon(Icons.check_circle_outline),
              //   label: const Text("Xác nhận đã thanh toán"),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.green,
              //     minimumSize: const Size(double.infinity, 50),
              //   ),
              //   onPressed: () {
              //     Navigator.pop(context);
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(content: Text("Đơn hàng của bạn đã được xác nhận!")),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
