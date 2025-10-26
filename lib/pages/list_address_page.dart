import 'package:flutter/material.dart';
import '../model/user_profile.dart';
import '../services/api_get_profile_service.dart';
import 'add_address_page.dart';
import 'edit_address_page.dart';

class ListAddressPage extends StatefulWidget {
  const ListAddressPage({super.key});

  @override
  State<ListAddressPage> createState() => _ListAddressPageState();
}

class _ListAddressPageState extends State<ListAddressPage> {
  late Future<List<UserAddress>> _futureAddresses;

  @override
  void initState() {
    super.initState();
    _futureAddresses = GetProfileService().getAddresses(); // ✅ gọi đúng service mới
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sổ địa chỉ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: FutureBuilder<List<UserAddress>>(
        future: _futureAddresses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('❌ Lỗi tải địa chỉ: ${snapshot.error}');
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final addresses = snapshot.data ?? [];
          if (addresses.isEmpty) {
            return const Center(child: Text('Chưa có địa chỉ nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.home_outlined, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            addr.line.isNotEmpty ? addr.line : 'Địa chỉ không xác định',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (addr.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'MẶC ĐỊNH',
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          ),
                        const SizedBox(width: 8),
                        // 🔹 Nút Edit
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditAddressPage(
                                  id: addr.id,
                                  // line: addr.line,
                                  // ward: addr.ward,
                                  // district: addr.district,
                                  // province: addr.province,
                                  // isDefault: addr.isDefault,
                                ),
                              ),
                            );
                            if (result != null && mounted) {
                              setState(() {
                                _futureAddresses =
                                    GetProfileService().getAddresses();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${addr.ward}, ${addr.district}, ${addr.province}",
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAddressPage()),
                );
                if (result != null && mounted) {
                  setState(() {
                    _futureAddresses = GetProfileService().getAddresses();
                  });
                }

              },
              child: const Text(
                'Thêm địa chỉ mới',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
