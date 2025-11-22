import 'package:flutter/material.dart';
import '../services/api_chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String? token;

  const ChatScreen({super.key, this.token});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiChatService chatService = ApiChatService();
  final ScrollController scrollController = ScrollController();
  final TextEditingController msgController = TextEditingController();

  List<Map<String, dynamic>> messages = [];

  @override
  // void initState() {
  //   super.initState();
  //
  //   chatService.token = widget.token;
  //
  //   chatService.onLoadHistory = (history) {
  //     setState(() {
  //       messages = List<Map<String, dynamic>>.from(history);
  //     });
  //
  //     scrollToEnd();
  //   };
  //
  //   chatService.onReceiveMessage = (msg) {
  //     setState(() => messages.add(msg));
  //
  //     scrollToEnd();
  //   };
  //
  //   chatService.connect();
  // }
  void initState() {
    super.initState();

    chatService.init().then((_) {
      chatService.onLoadHistory = (history) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(history);
        });
        scrollToEnd();
      };

      chatService.onReceiveMessage = (msg) {
        setState(() => messages.add(msg));
        scrollToEnd();
      };

      chatService.connect();
    });
  }


  void scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    chatService.disconnect();
    scrollController.dispose();
    msgController.dispose();
    super.dispose();
  }

  void send() {
    final text = msgController.text.trim();
    if (text.isEmpty) return;

    chatService.sendMessage(text);
    msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:  Text("Chat hỗ trợ",style: TextStyle(color: Colors.white,fontSize: 28, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg["senderType"] == "USER";

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.redAccent : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isMe
                            ? null
                            : Border.all(color: Colors.black12),
                      ),
                      constraints: const BoxConstraints(maxWidth: 270),
                      child: Column(
                        crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg["content"] ?? "",
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black, fontSize: 17, fontWeight: FontWeight.w400
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatTime(msg["createdAt"]),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:
                              isMe ? Colors.white70 : Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // INPUT BOX
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      decoration: const InputDecoration(
                        hintText: "Nhập tin nhắn...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide(
                            color: Colors.grey, // màu viền
                            width: 1.5,        // độ dày viền
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide(
                            color: Colors.grey, // màu viền khi chưa focus
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide(
                            color: Colors.grey, // màu viền khi focus
                            width: 1.5,
                          ),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => send(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: send,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.redAccent,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String formatTime(String? dateStr) {
    if (dateStr == null) return "";

    final date = DateTime.tryParse(dateStr);
    if (date == null) return "";

    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
