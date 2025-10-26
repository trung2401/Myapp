import 'package:flutter/material.dart';
import '../model/user_profile.dart';
import '../services/api_get_profile_service.dart';
import '../services/api_edit_address_service.dart';

class EditAddressPage extends StatefulWidget {
  final int id; // nhận id từ trang trước

  const EditAddressPage({super.key,required this.id});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  late Future<UserAddress?> _futureAddress;

  // Controllers
  final TextEditingController _lineController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();

  bool _isDefault = false;// radio button

  @override
  void initState() {
    super.initState();
    _futureAddress = _loadAddress();
  }

  Future<UserAddress?> _loadAddress() async {
    try {
      final addresses = await GetProfileService().getAddresses();
      final address =
      addresses.firstWhere((a) => a.id == widget.id, orElse: () => throw Exception('Không tìm thấy địa chỉ'));
      _lineController.text = address.line;
      _wardController.text = address.ward;
      _districtController.text = address.district;
      _provinceController.text = address.province;
      _isDefault = address.isDefault;
      return address;
    } catch (e) {
      debugPrint('❌ Lỗi load địa chỉ: $e');
      return null;
    }
  }

  Future<void> _updateAddress(int id) async {
    try {
      await EditAddressService().updateAddress(
        id: id,
        line: _lineController.text,
        ward: _wardController.text,
        district: _districtController.text,
        province: _provinceController.text,
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
    }
  }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _buildLabel("TỈNH/ THÀNH PHỐ"),
                      TextField(
                        controller: _provinceController,
                        decoration: const InputDecoration(border: UnderlineInputBorder()),
                      ),

                      const SizedBox(height: 8),
                      _buildLabel("QUẬN/ HUYỆN"),
                      TextField(
                        controller: _districtController,
                        decoration: const InputDecoration(border: UnderlineInputBorder()),
                      ),

                      const SizedBox(height: 8),
                      _buildLabel("PHƯỜNG/ XÃ"),
                      TextField(
                        controller: _wardController,
                        decoration: const InputDecoration(border: UnderlineInputBorder()),
                      ),

                      const SizedBox(height: 8),
                      _buildLabel("ĐỊA CHỈ"),
                      TextField(
                        controller: _lineController,
                        decoration: const InputDecoration(border: UnderlineInputBorder()),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _isDefault,
                            onChanged: (v) => setState(() => _isDefault = v ?? false),
                          ),
                          const Text("Đặt làm địa chỉ mặc định"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

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

                // Nút Cập nhật
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _updateAddress(address.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Cập nhật", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
    );
  }
}
