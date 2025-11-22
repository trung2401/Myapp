import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ApiChatService {
  StompClient? stompClient;

  String? token;
  String? guestId;

  int unreadCount = 0;

  // Callback khi load history
  Function(List<dynamic>)? onLoadHistory;

  // Callback khi nhận tin nhắn mới
  Function(Map<String, dynamic>)? onReceiveMessage;

  // Callback khi thay đổi unread badge
  Function(int)? onUnreadChange;

  bool _connected = false;

  ApiChatService();

  // Khởi tạo token + guest ID
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString("jwtToken");

    guestId = prefs.getString("guestId");
    if (guestId == null) {
      guestId = const Uuid().v4();
      await prefs.setString("guestId", guestId!);
    }

    print("🔐 Token: $token");
    print("🟦 Guest ID: $guestId");
  }

  Future<void> saveToken(String? newToken) async {
    final prefs = await SharedPreferences.getInstance();

    if (newToken != null && newToken.trim().isNotEmpty) {
      await prefs.setString("jwtToken", newToken.trim());
      token = newToken.trim();
    } else {
      await prefs.remove("jwtToken");
      token = null;
    }
  }

  // Kết nối WebSocket
  void connect() {
    if (_connected) return;

    String url = "wss://api.motchillx.site/ws/customer?";

    if (token != null && token!.length > 20) {
      url += "token=${Uri.encodeComponent(token!)}";
      print("🔐 Đang dùng JWT: $token");
    } else {
      url += "guestId=$guestId";
      print("🟦 Đang dùng Guest ID: $guestId");
    }

    stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: _onConnected,
        onWebSocketError: (err) => print("❌ WebSocket error: $err"),
        onStompError: (frame) => print("❌ STOMP error: ${frame.body}"),
        onDisconnect: (frame) => print("🔌 Disconnected"),
        stompConnectHeaders: {},
        webSocketConnectHeaders: {},
      ),
    );

    stompClient!.activate();
  }

  // Khi WebSocket kết nối thành công
  void _onConnected(StompFrame frame) {
    _connected = true;
    print("✅ Connected STOMP");

    // Nhận lịch sử chat
    stompClient!.subscribe(
      destination: "/user/queue/chat_init",
      callback: (msg) {
        List<dynamic> history = jsonDecode(msg.body!);
        if (onLoadHistory != null) {
          onLoadHistory!(history);
        }
      },
    );

    // Nhận tin nhắn mới
    stompClient!.subscribe(
      destination: "/user/queue/chat",
      callback: (msg) {
        Map<String, dynamic> data = jsonDecode(msg.body!);

        unreadCount++;
        onUnreadChange?.call(unreadCount);

        if (onReceiveMessage != null) {
          onReceiveMessage!(data);
        }
      },
    );

    // Gửi yêu cầu load history
    stompClient!.send(destination: "/app/chat.load_history");
  }

  // Reset badge khi mở chat
  void resetUnread() {
    unreadCount = 0;
    onUnreadChange?.call(0);
  }

  // Gửi tin nhắn
  void sendMessage(String text) {
    if (!_connected) return;

    stompClient!.send(
      destination: "/app/chat.send",
      body: jsonEncode({"content": text}),
    );
    print("🔐 Token: $token");
    print("🟦 Guest ID: $guestId");
  }

  void disconnect() {
    stompClient?.deactivate();
    _connected = false;
  }
}
