import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // 👉 cần thêm thư viện này

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
    // 👉 Giả sử API trả về paymentInfo chứa link hoặc text QR
    final qrData = paymentInfo['qrData'] ?? 'Không có dữ liệu QR';
    print("🔍 QR DATA từ API:");
    print(paymentInfo['qrData']);
    print(paymentInfo);

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

              // --- QR hiển thị ---
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
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
              const SizedBox(height: 32),

              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Xác nhận đã thanh toán"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đơn hàng của bạn đã được xác nhận!")),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
