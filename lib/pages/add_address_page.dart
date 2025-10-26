import 'package:flutter/material.dart';
import '../services/api_add_address_service.dart';
import '../model/user_profile.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _lineController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _lineController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final service = AddAddressService();
      final newAddress = await service.addAddress(
        line: _lineController.text.trim(),
        ward: _wardController.text.trim(),
        district: _districtController.text.trim(),
        province: _provinceController.text.trim(),
        isDefault: _isDefault,
      );

      if (mounted) {
        Navigator.pop(context, newAddress); // quay lại trang trước và trả về địa chỉ vừa thêm
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
              TextFormField(
                controller: _lineController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ chi tiết (số nhà, đường,...)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _wardController,
                decoration: const InputDecoration(
                  labelText: 'Phường/Xã',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập phường/xã' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(
                  labelText: 'Quận/Huyện',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập quận/huyện' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _provinceController,
                decoration: const InputDecoration(
                  labelText: 'Tỉnh/Thành phố',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập tỉnh/thành phố' : null,
              ),
              const SizedBox(height: 12),
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
