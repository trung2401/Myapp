class ProductDetailInfo {
  final String displaySize;          // Kích thước màn hình
  final String screenTechnology;    // Công nghệ màn hình
  final String cameraRear;          // Camera sau
  final String cameraFront;         // Camera trước
  final String chipset;             // Chipset
  final String nfc;                 // Công nghệ NFC
  // final String ram;                 // Dung lượng RAM
  final String storage;             // Bộ nhớ trong
  final String battery;             // Pin
  final String sim;                 // Thẻ SIM
  final String osVersion;           // Hệ điều hành
  final String displayResolution;   // Độ phân giải màn hình
  final String displayFeatures;     // Tính năng màn hình
  final String cpuType;             // Loại CPU

  ProductDetailInfo({
    required this.displaySize,
    required this.screenTechnology,
    required this.cameraRear,
    required this.cameraFront,
    required this.chipset,
    required this.nfc,
    // required this.ram,
    required this.storage,
    required this.battery,
    required this.sim,
    required this.osVersion,
    required this.displayResolution,
    required this.displayFeatures,
    required this.cpuType,
  });

  factory ProductDetailInfo.fromJson(Map<String, dynamic> json) {
    return ProductDetailInfo(
      displaySize: json['display_size'] ?? '',
      screenTechnology: json['iphone_man_hinh'] ?? '',
      cameraRear: json['camera_primary'] ?? '',
      cameraFront: json['camera_secondary'] ?? '',
      chipset: json['chipset'] ?? '',
      nfc: json['mobile_nfc'] ?? '',
      // ram: json['memory_internal'] ?? '',
      storage: json['related_name'] ?? '',
      battery: json['battery'] ?? '',
      sim: json['sim'] ?? '',
      osVersion: json['os_version'] ?? '',
      displayResolution: json['display_resolution'] ?? '',
      displayFeatures: json['mobile_display_features'] ?? '',
      cpuType: json['cpu'] ?? '',
    );
  }
}
