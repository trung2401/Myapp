import 'package:flutter/material.dart';
import '../model/location_model.dart';
import '../model/user_profile.dart';
import '../services/api_get_profile_service.dart';
import '../services/api_edit_address_service.dart';
import '../services/location_service.dart';

class EditAddressPage extends StatefulWidget {
  final int id; // nhận id từ trang trước

  const EditAddressPage({super.key, required this.id});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _lineController = TextEditingController();
  bool _isDefault = false;
  bool _isSaving = false;

  final locationService = LocationService();

  // Dropdown data
  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  bool isLoadingProvince = true;
  bool isLoadingDistrict = false;
  bool isLoadingWard = false;

  late Future<UserAddress?> _futureAddress;

  @override
  void initState() {
    super.initState();
    _futureAddress = _loadAddress();
    _loadProvinces();
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  Future<UserAddress?> _loadAddress() async {
    try {
      final addresses = await GetProfileService().getAddresses();
      final address =
      addresses.firstWhere((a) => a.id == widget.id, orElse: () => throw Exception('Không tìm thấy địa chỉ'));
      _lineController.text = address.line;
      _isDefault = address.isDefault;

      // Gán province/district/ward hiện tại
      if (provinces.isNotEmpty) {
        try {
          selectedProvince = provinces.firstWhere((p) => p.name == address.province);
        } catch (e) {
          selectedProvince = null;
        }

        if (selectedProvince != null) {
          await _loadDistricts(selectedProvince!.code);
          try {
            selectedDistrict = districts.firstWhere((d) => d.name == address.district);
          } catch (e) {
            selectedDistrict = null;
          }

          if (selectedDistrict != null) {
            await _loadWards(selectedDistrict!.code);
            try {
              selectedWard = wards.firstWhere((w) => w.name == address.ward);
            } catch (e) {
              selectedWard = null;
            }
          }
        }
      }


      setState(() {});
      return address;
    } catch (e) {
      debugPrint('❌ Lỗi load địa chỉ: $e');
      return null;
    }
  }

  // ===== Load provinces/districts/wards =====
  Future<void> _loadProvinces() async {
    setState(() => isLoadingProvince = true);
    try {
      provinces = await locationService.getProvinces();
    } catch (e) {
      debugPrint('❌ Lỗi load provinces: $e');
    }
    setState(() => isLoadingProvince = false);
  }

  Future<void> _loadDistricts(String provinceCode) async {
    setState(() => isLoadingDistrict = true);
    try {
      districts = await locationService.getDistricts(provinceCode);
      selectedDistrict = null;
      selectedWard = null;
      wards = [];
    } catch (e) {
      debugPrint('❌ Lỗi load districts: $e');
    }
    setState(() => isLoadingDistrict = false);
  }

  Future<void> _loadWards(String districtCode) async {
    setState(() => isLoadingWard = true);
    try {
      wards = await locationService.getWards(districtCode);
      selectedWard = null;
    } catch (e) {
      debugPrint('❌ Lỗi load wards: $e');
    }
    setState(() => isLoadingWard = false);
  }

  // ===== Update address =====
  Future<void> _updateAddress(int id) async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedProvince == null || selectedDistrict == null || selectedWard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn đủ tỉnh, huyện, xã")),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await EditAddressService().updateAddress(
        id: id,
        line: _lineController.text.trim(),
        province: selectedProvince!.name,
        district: selectedDistrict!.name,
        ward: selectedWard!.name,
        isDefault: _isDefault,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Cập nhật thành công")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi cập nhật: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ===== Delete address =====
  Future<void> _deleteAddress(int id) async {
    try {
      await EditAddressService().deleteAddress(id: id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🗑️ Xóa địa chỉ thành công")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi khi xóa: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa địa chỉ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: FutureBuilder<UserAddress?>(
        future: _futureAddress,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Không tải được thông tin địa chỉ"));
          }

          final address = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ===== Province dropdown =====
                  DropdownButtonFormField<Province>(
                    decoration: const InputDecoration(
                      labelText: "Tỉnh/Thành phố",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedProvince,
                    items: isLoadingProvince
                        ? [const DropdownMenuItem(child: Text("Đang tải..."))]
                        : provinces.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                    onChanged: (value) {
                      setState(() => selectedProvince = value);
                      if (value != null) _loadDistricts(value.code);
                    },
                    validator: (value) => value == null ? "Chọn tỉnh/thành phố" : null,
                  ),
                  const SizedBox(height: 16),

                  // ===== District dropdown =====
                  DropdownButtonFormField<District>(
                    decoration: const InputDecoration(
                      labelText: "Quận/Huyện",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedDistrict,
                    items: isLoadingDistrict
                        ? [const DropdownMenuItem(child: Text("Đang tải..."))]
                        : districts.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                    onChanged: (value) {
                      setState(() => selectedDistrict = value);
                      if (value != null) _loadWards(value.code);
                    },
                    validator: (value) => value == null ? "Chọn quận/huyện" : null,
                  ),
                  const SizedBox(height: 16),

                  // ===== Ward dropdown =====
                  DropdownButtonFormField<Ward>(
                    decoration: const InputDecoration(
                      labelText: "Phường/Xã",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedWard,
                    items: isLoadingWard
                        ? [const DropdownMenuItem(child: Text("Đang tải..."))]
                        : wards.map((w) => DropdownMenuItem(value: w, child: Text(w.name))).toList(),
                    onChanged: (value) => setState(() => selectedWard = value),
                    validator: (value) => value == null ? "Chọn phường/xã" : null,
                  ),
                  const SizedBox(height: 16),

                  // ===== Line =====
                  TextFormField(
                    controller: _lineController,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ chi tiết (số nhà, đường,...)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                  ),
                  const SizedBox(height: 12),

                  // ===== Default checkbox =====
                  CheckboxListTile(
                    value: _isDefault,
                    onChanged: (v) => setState(() => _isDefault = v ?? false),
                    title: const Text('Đặt làm địa chỉ mặc định'),
                  ),

                  const SizedBox(height: 16),

                  // Nút Xóa
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text("Xóa địa chỉ", style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFE0E0)),
                        backgroundColor: const Color(0xFFFFEEEE),
                      ),
                      onPressed: () => _deleteAddress(address.id),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nút cập nhật
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _updateAddress(address.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Cập nhật", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
