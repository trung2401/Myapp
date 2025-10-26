class AddCartResponse {
  final int code;
  final String message;
  final String timestamp;
  final dynamic data;

  AddCartResponse({
    required this.code,
    required this.message,
    required this.timestamp,
    this.data,
  });

  factory AddCartResponse.fromJson(Map<String, dynamic> json) {
    return AddCartResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
      data: json['data'],
    );
  }
}
