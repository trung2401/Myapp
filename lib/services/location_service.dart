import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/location_model.dart';

class LocationService {
  static const String baseUrl = "https://provinces.open-api.vn/api/v1";

  Future<List<Province>> getProvinces() async {
    final res = await http.get(Uri.parse("$baseUrl/p/"));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Province.fromJson(e)).toList();
    } else {
      throw Exception("Lỗi load provinces: ${res.body}");
    }
  }

  Future<List<District>> getDistricts(String provinceCode) async {
    final res = await http.get(Uri.parse("$baseUrl/p/$provinceCode?depth=2"));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List districtsData = data['districts'] ?? [];
      return districtsData.map((e) => District.fromJson(e)).toList();
    } else {
      throw Exception("Lỗi load districts: ${res.body}");
    }
  }

  Future<List<Ward>> getWards(String districtCode) async {
    final res = await http.get(Uri.parse("$baseUrl/d/$districtCode?depth=2"));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List wardsData = data['wards'] ?? [];
      return wardsData.map((e) => Ward.fromJson(e)).toList();
    } else {
      throw Exception("Lỗi load wards: ${res.body}");
    }
  }
}
