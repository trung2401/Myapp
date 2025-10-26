import 'package:flutter/material.dart';

import '../screens/category_screen.dart';
import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }

}

class _HomePageState extends State<HomePage>{
  int curentIndex = 0;
  List screen = [
    HomeScreen(),
    CategoryScreen(),
    CartScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo/branch.jpg', width: 200, height: 200),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15), // 👈 bo cong cạnh dưới
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.redAccent, // xanh đậm
                Colors.redAccent, // xanh nhạt vừa
              ],
            ),
          ),
        ),
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Xử lý khi bấm chuông
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60), // chiều cao của thanh search
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Bạn muốn mua gì hôm nay?",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.black, size: 25),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 5),
                ),
              ),
            ),
          ),
        ),
      ),
      body: screen[curentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: curentIndex,
        onTap: (index) {
          setState(() {
            curentIndex = index;
          });
        },
        selectedItemColor: Colors.redAccent,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'danh mục',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'giỏ hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'tài khoản',
          ),
        ],
      ),
    );
  }
  
}