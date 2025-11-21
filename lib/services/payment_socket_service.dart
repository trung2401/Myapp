import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class PaymentSocketService {
  StompClient? _client;
  bool _connected = false;
  bool _subscribed = false;

  Function()? onPaid;

  void connect(String orderId) {
    if (_connected) return;

    _client = StompClient(
      config: StompConfig(
        url: "wss://api.motchillx.site/ws/public",
        onConnect: (frame) {
          _connected = true;

          if (!_subscribed) {
            _client!.subscribe(
              destination: "/topic/$orderId",
              callback: (StompFrame msg) {
                _handleMessage(msg.body);
              },
            );
            _subscribed = true;
          }
        },
        onWebSocketError: (err) {
          debugPrint("❌ SOCKET ERROR: $err");
        },
      ),
    );

    _client!.activate();
  }

  void _handleMessage(String? body) {
    if (body == null) return;

    debugPrint("📩 SOCKET MESSAGE: $body");

    bool success = false;

    if (body == "PAID" || body == '"PAID"') {
      success = true;
    } else {
      try {
        final data = jsonDecode(body);
        if (data['status'] == "PAID") {
          success = true;
        }
      } catch (_) {}
    }

    if (success && onPaid != null) {
      onPaid!(); // 🔥 Gọi callback báo đã thanh toán
    }
  }

  void disconnect() {
    if (_client != null && _connected) {
      _client!.deactivate();
    }
    _connected = false;
    _subscribed = false;
    print('disconnect');
  }
}
