class LoginResponse {
  final int code;
  final String timestamp;
  final LoginData? data;

  LoginResponse({
    required this.code,
    required this.timestamp,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      code: json['code'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }
}

class LoginData {
  final String? accessToken;
  final String? refreshToken;

  LoginData({
    this.accessToken,
    this.refreshToken,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
