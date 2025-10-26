import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_edit_profile_service.dart';
import '../services/api_get_profile_service.dart';
import '../model/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;

  bool isLoading = true;
  UserProfile? user;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profileService = GetProfileService();
      final profile = await profileService.getProfile();
      setState(() {
        user = profile;
        _nameController.text = profile.name ?? "";
        _gender = profile.gender ?? "Nam";
        if (profile.birth != null && profile.birth!.isNotEmpty) {
          _birthDate = DateTime.tryParse(profile.birth!);
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("⚠️ Lỗi tải thông tin: $e")));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final formattedBirth =
      _birthDate != null ? "${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}" : "";

      final service = EditProfileService();
      await service.updateProfile(
        name: _nameController.text,
        gender: _gender ?? "Nam",
        birth: formattedBirth,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Cập nhật thành công!")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Lỗi cập nhật: $e")));
    }
  }

  void _selectBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40, bottom: 0, left: 16, right: 16),
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.only(top: 40,bottom: 40,left: 10,right: 10),
            decoration: BoxDecoration(
              color: Colors.white, // Nền trắng
              border: Border.all(
                color: Colors.grey.shade300, // Màu viền (có thể đổi sang Colors.black)
                width: 1.5, // Độ dày viền
              ),
              borderRadius: BorderRadius.circular(12), // Bo tròn các góc
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4), // Đổ bóng nhẹ bên dưới
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/logo/user.jpg')
                ),
                const SizedBox(height: 20),
                // Họ tên
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Họ và tên",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Nhập họ tên" : null,
                ),
                const SizedBox(height: 20),

                // Giới tính
                Row(
                  children: [
                    const Text("Giới tính: "),
                    Expanded(
                      child: Row(
                        children: [
                          Radio<String>(
                            value: "Nam",
                            groupValue: _gender,
                            onChanged: (val) =>
                                setState(() => _gender = val),
                          ),
                          const Text("Nam"),
                          Radio<String>(
                            value: "Nữ",
                            groupValue: _gender,
                            onChanged: (val) =>
                                setState(() => _gender = val),
                          ),
                          const Text("Nữ"),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Ngày sinh
                InkWell(
                  onTap: _selectBirthDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Ngày sinh",
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _birthDate == null
                          ? "Chưa chọn ngày"
                          : "${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}",
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Các trường khác chỉ đọc
                if (user != null) ...[
                  TextFormField(
                    initialValue: user!.email ?? "Không có email",
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: user!.phone ?? "Không có số điện thoại",
                    decoration: const InputDecoration(
                      labelText: "Số điện thoại",
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 30),
                ],

                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text("Lưu thay đổi"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
