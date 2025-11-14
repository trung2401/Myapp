import 'package:flutter/material.dart';
import '../services/api_add_address_service.dart';
import '../services/location_service.dart';
import '../model/location_model.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _lineController = TextEditingController();
  bool _isDefault = false;
  bool _isSaving = false;

  // ===== Dropdown data =====
  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  bool isLoadingProvince = true;
  bool isLoadingDistrict = false;
  bool isLoadingWard = false;

  final locationService = LocationService();

  @override
  void initState() {
    super.initState();
    loadProvinces();
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  // ===== Load provinces / districts / wards =====
  Future<void> loadProvinces() async {
    setState(() => isLoadingProvince = true);
    try {
      provinces = await locationService.getProvinces();
    } catch (e) {
      print("❌ Lỗi load provinces: $e");
    }
    setState(() => isLoadingProvince = false);
  }

  Future<void> loadDistricts(String provinceCode) async {
    setState(() => isLoadingDistrict = true);
    try {
      districts = await locationService.getDistricts(provinceCode);
      selectedDistrict = null;
      selectedWard = null;
      wards = [];
    } catch (e) {
      print("❌ Lỗi load districts: $e");
    }
    setState(() => isLoadingDistrict = false);
  }

  Future<void> loadWards(String districtCode) async {
    setState(() => isLoadingWard = true);
    try {
      wards = await locationService.getWards(districtCode);
      selectedWard = null;
    } catch (e) {
      print("❌ Lỗi load wards: $e");
    }
    setState(() => isLoadingWard = false);
  }

  // ===== Save address =====
  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedProvince == null || selectedDistrict == null || selectedWard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn đủ tỉnh, huyện, xã")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = AddAddressService();
      final newAddress = await service.addAddress(
        line: _lineController.text.trim(),
        province: selectedProvince!.name,
        district: selectedDistrict!.name,
        ward: selectedWard!.name,
        isDefault: _isDefault,
      );

      if (mounted) {
        Navigator.pop(context, newAddress);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Thêm địa chỉ thành công')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi khi thêm địa chỉ: $e')),
      );
      print(e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ===== Build UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm địa chỉ mới', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ===== Province =====
              DropdownButtonFormField<Province>(
                decoration: const InputDecoration(
                  labelText: "Tỉnh/Thành phố",
                  border: OutlineInputBorder(),
                ),
                value: selectedProvince,
                items: isLoadingProvince
                    ? [const DropdownMenuItem(child: Text("Đang tải..."))]
                    : provinces
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedProvince = value);
                  if (value != null) loadDistricts(value.code);
                },
                validator: (value) => value == null ? "Chọn tỉnh/thành phố" : null,
              ),
              const SizedBox(height: 16),

              // ===== District =====
              DropdownButtonFormField<District>(
                decoration: const InputDecoration(
                  labelText: "Quận/Huyện",
                  border: OutlineInputBorder(),
                ),
                value: selectedDistrict,
                items: isLoadingDistrict
                    ? [const DropdownMenuItem(child: Text("Đang tải..."))]
                    : districts
                    .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedDistrict = value);
                  if (value != null) loadWards(value.code);
                },
                validator: (value) => value == null ? "Chọn quận/huyện" : null,
              ),
              const SizedBox(height: 16),

              // ===== Ward =====
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

              // ===== Default address checkbox =====
              CheckboxListTile(
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val ?? false),
                title: const Text('Đặt làm địa chỉ mặc định'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Thêm địa chỉ mới',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
