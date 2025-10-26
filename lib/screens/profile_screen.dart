import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/edit_profile_page.dart';
import '../pages/list_address_page.dart';
import '../pages/login_page.dart';
import '../services/api_get_profile_service.dart';
import '../model/user_profile.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  UserProfile? user;
  final String baseUrl = "https://res.cloudinary.com/doy1zwhge/image/upload";
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');

      if (token == null) {
        // nếu chưa đăng nhập, chuyển về login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
        return;
      }

      final profileService = GetProfileService();
      final profile = await profileService.getProfile();

      setState(() {
        user = profile;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Lỗi tải thông tin: $e')),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
    await prefs.remove('refreshToken');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng xuất thành công!')),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.only(top: 24, bottom: 40),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: user?.avatar != null && user!.avatar!.isNotEmpty
                    ? NetworkImage(
                  user!.avatar!.startsWith('http')
                      ? user!.avatar! // đã là URL đầy đủ
                      : "$baseUrl${user!.avatar!}", // là path thì ghép baseUrl
                )
                    : const AssetImage('assets/logo/user.jpg') as ImageProvider,
                onBackgroundImageError: (_, __) {
                  // Nếu ảnh lỗi thì không crash
                },
              ),

              const SizedBox(height: 12),
              Text(
                user?.name ?? 'Không có tên',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.phone ?? 'Không có số điện thoại',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              ProfileMenuItem(
                icon: Icons.person_outline,
                text: 'Thông tin cá nhân',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(user: user!),
                    ),
                  ).then((updatedUser) {
                    if (updatedUser != null) {
                      setState(() {
                        user = updatedUser;
                      });
                    }
                  });

                },
              ),
              ProfileMenuItem(
                icon: Icons.add_location_alt_outlined,
                text: 'Sổ địa chỉ',
                onTap: () {
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListAddressPage(),
                      ),
                    );
                  }
                },
              ),
              ProfileMenuItem(
                icon: Icons.edit_location_alt_outlined,
                text: 'Thêm địa chỉ',
                onTap: () {

                },
              ),
              ProfileMenuItem(
                icon: Icons.shopping_bag_outlined,
                text: 'Đơn hàng của tôi',
                onTap: () {},
              ),


              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
