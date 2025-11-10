import 'package:flutter/material.dart';
import 'package:myapp/services/api_product_service.dart';
import '../model/product.dart';
import '../widgets/product_card.dart';
import '../model/category.dart' as myCat;
import '../services/api_get_attribute_filter_service.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/series_row_widget.dart'; // file chứa hàm showFilterBottomSheet

class ListProductPage extends StatefulWidget {
  final myCat.Category category;
  const ListProductPage({super.key, required this.category});

  @override
  State<ListProductPage> createState() => _ListProductPageState();
}

class _ListProductPageState extends State<ListProductPage> {
  List<Product> products = [];
  bool isLoading = true;
  String? errorMessage;
  String sortType = "popular"; // mặc định
  bool isAscending = true; // cho sắp xếp giá

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final fetchedProducts =
      await ApiProductService.fetchProducts(
        categorySlug: widget.category.slug,
        page: 1,
        size: 20,
      );

      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Bộ lọc
  Future<void> _openFilter() async {
    final selectedFilters = await showFilterBottomSheet(context, widget.category.slug);
    if (selectedFilters != null) {
      setState(() => isLoading = true);

      try {
        final filteredProducts = await ApiProductService.fetchProducts(
          categorySlug: widget.category.slug,
          page: 1,
          size: 20,
          order: sortType == "discount" ? "discount" : "id",
          dir: isAscending ? "asc" : "desc",
          params: selectedFilters.map((key, value) => MapEntry(key.toString(), value.toString())),
        );

        setState(() {
          products = filteredProducts; // 🔥 Cập nhật danh sách sản phẩm
          isLoading = false;
        });

        print("Filters đã chọn: $selectedFilters");
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi lọc sản phẩm: $e")),
        );
      }
    }
  }


  void _sortByPrice() {
    setState(() {
      isAscending = !isAscending;
      products.sort((a, b) {
        final priceA = a.price ?? 0;
        final priceB = b.price ?? 0;
        return isAscending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        elevation: 0,
        title: Text(
          widget.category.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSortBar(),
          const SizedBox(height: 10),
          // 🆕 series theo brand
          SeriesRowWidget(
            brandSlug: widget.category.slug,
            onSelect: (selectedSeries) {
              print("🔹 Chọn series: ${selectedSeries.name}");
              setState(() {
                isLoading = true;
              });
              ApiProductService.fetchProducts(
                categorySlug: selectedSeries.slug,
                page: 1,
                size: 20,
              ).then((fetchedProducts) {
                setState(() {
                  products = fetchedProducts;
                  isLoading = false;
                });
              });
            },
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : _buildListProduct(),
          ),
        ],
      ),

    );
  }

  /// 🔹 Thanh điều hướng sắp xếp (Phổ biến | Khuyến mãi | Giá | Bộ lọc)
  Widget _buildSortBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sortButton("Phổ biến", sortType == "popular", () {
            setState(() => sortType = "popular");
          }),
          // _sortButton("Khuyến mãi", sortType == "discount", () {
          //   setState(() => sortType = "discount");
          // }),
          TextButton.icon(
            onPressed: _sortByPrice,
            icon: Icon(
              isAscending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.black,
            ),
            label: const Text(
              "Giá",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),
          TextButton.icon(
            onPressed: _openFilter,
            label: const Text(
              "Bộ lọc",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            icon: Icon(Icons.filter_list, color: Colors.black),
          ),
        ],
      ),
    );
  }

  /// 🔹 Nút sắp xếp (có gạch chân khi đang chọn)
  Widget _sortButton(String label, bool isSelected, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.redAccent : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected)
            Container(
              height: 2,
              width: 30,
              margin: const EdgeInsets.only(top: 2),
              color: Colors.redAccent,
            ),
        ],
      ),
    );
  }

  /// 🔹 Lưới hiển thị sản phẩm
  Widget _buildListProduct() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(product: product);
      },
    );
  }
}
