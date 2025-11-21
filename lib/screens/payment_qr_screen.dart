import 'package:flutter/material.dart';
import 'package:myapp/widgets/count_down_time_widget.dart';
import '../pages/home_page.dart';
import '../services/payment_socket_service.dart';

class PaymentQrScreen extends StatefulWidget {
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
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  final socketService = PaymentSocketService();

  @override
  void initState() {
    super.initState();

    socketService.onPaid = () {
      socketService.disconnect(); // đóng socket

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thanh toán thành công!")),
      );
    };

    socketService.connect(widget.orderId); // 🔥 mở socket
  }

  @override
  void dispose() {
    socketService.disconnect(); // đóng socket khi rời màn
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qrUrl = widget.paymentInfo['qrCodeUrl'] ?? '';

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

              Image.network(
                qrUrl,
                width: 220,
                height: 220,
                errorBuilder: (ctx, error, stack) {
                  return const Text("Không tải được QR");
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: CountdownTimerWidget(
                  minutes: 5,
                  onTimeout: () {
                    socketService.disconnect();// đóng socket
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                            (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("thanh toán bị huỷ vì quá hạn!")),
                    );
                  },

                ),
              ),

              const SizedBox(height: 24),

              Text("Mã đơn hàng: ${widget.orderId}"),
              const SizedBox(height: 8),
              Text(
                "Số tiền: ${widget.amount.toStringAsFixed(0)}đ",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
