class UserProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String birth;
  final String avatar;
  final bool isActive;
  final bool isGuest;
  final List<String> roles;
  final int totalOrders;
  final double totalAmountSpent;
  final List<UserAddress> addresses;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birth,
    required this.avatar,
    required this.isActive,
    required this.isGuest,
    required this.roles,
    required this.totalOrders,
    required this.totalAmountSpent,
    required this.addresses,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      birth: json['birth'] ?? '',
      avatar: json['avatar'] ?? '',
      isActive: json['isActive'] ?? false,
      isGuest: json['isGuest'] ?? false,
      roles: List<String>.from(json['roles'] ?? []),
      totalOrders: json['totalOrders'] ?? 0,
      totalAmountSpent:
      (json['totalAmountSpent'] ?? 0).toDouble(),
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((e) => UserAddress.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class UserAddress {
  final int id;
  final String phone;
  final String line;
  final String ward;
  final String district;
  final String province;
  final bool isDefault;

  UserAddress({
    required this.id,
    required this.phone,
    required this.line,
    required this.ward,
    required this.district,
    required this.province,
    required this.isDefault,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] ?? 0,
      phone: json['phone'] ?? '',
      line: json['line'] ?? '',
      ward: json['ward'] ?? '',
      district: json['district'] ?? '',
      province: json['province'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}
