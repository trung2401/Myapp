import 'package:flutter/material.dart';

import '../model/my_product.dart';
import '../model/product.dart';
import '../services/api_product_service.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int isSelected = 0;
  late Future<List<Product>> _phonesFuture;
  late Future<List<Product>> _laptopsFuture;

  @override
  void initState() {
    super.initState();
    _phonesFuture = ApiProductService.fetchProducts("mobile", 1, 10);
    _laptopsFuture = ApiProductService.fetchProducts("laptop", 1, 10);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Điện Thoại nổi bật',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                ),
            ),
        
        
            // const SizedBox(height: 20),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     _BuildProductCategoty(index: 0, name: 'All Product'),
            //     _BuildProductCategoty(index: 1, name: 'Phone'),
            //     _BuildProductCategoty(index: 2, name: 'Laptop'),
            //   ],
            // ),
            const SizedBox(height: 20),

            /// ✅ Đây là chỗ cần thêm ListPhone
            SizedBox(
              height: 620,
              child: _BuildPhoneProduct(),
            ),
            const SizedBox(height: 10),
            Text(
              'Laptop nổi bật',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            /// ✅ Đây là chỗ cần thêm ListLaptop
            const SizedBox(height: 20),
            SizedBox(
              height: 620,
              child: _BuildLaptopProduct(),
            ),
        
            /// ✅ Đây là chỗ cần thêm GridView
            // Expanded(
            //   child: isSelected == 0
            //       ? _BuildAllProduct()
            //       : isSelected == 1
            //           ? _BuildPhoneProduct()
            //           : _BuildLaptopProduct(),
            // ),
          ],
        ),
      ),
    );
  }
  _BuildProductCategoty({required int index,required String name}){
    return GestureDetector(
      onTap:() {
        setState(() {
          isSelected = index;
        });
      },
      child: Container(
        width: 110,
        height: 50,
        // margin: const EdgeInsets.only(right: 22),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected == index ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // _BuildAllProduct(){
  //   return GridView.builder(
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 2,
  //       crossAxisSpacing: 10,
  //       mainAxisSpacing: 10,
  //       childAspectRatio: (100/140),
  //     ),
  //     scrollDirection: Axis.vertical,
  //     itemCount: MyProduct.allProduct.length,
  //     itemBuilder: (context, index){
  //       final allProdcuts = MyProduct.allProduct[index];
  //       return ProductCard(product: allProdcuts);
  //     },
  //   );
  // }
  Widget _BuildPhoneProduct(){
    final screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder<List<Product>>(
      future: _phonesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không có sản phẩm điện thoại"));
        }

        final phoneProducts = snapshot.data!;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: (screenWidth / 2) / 140,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: phoneProducts.length,
          itemBuilder: (context, index) {
            return ProductCard(product: phoneProducts[index]);
          },
        );
      },
    );
  }
  Widget _BuildLaptopProduct(){
    final screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder<List<Product>>(
      future: _laptopsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không có sản phẩm laptop"));
        }

        final laptopProducts = snapshot.data!;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            childAspectRatio: (screenWidth / 2) / 140,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: laptopProducts.length,
          itemBuilder: (context, index) {
            return ProductCard(product: laptopProducts[index]);
          },
        );
      },
    );
  }
}