import 'package:flutter/material.dart';
import '../model/product.dart';
import '../services/api_search_service.dart';
import '../widgets/product_card.dart';

class ProductSearchPage extends StatefulWidget {
  final String initialKeyword;

  const ProductSearchPage({super.key, required this.initialKeyword});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialKeyword;
    _fetchProducts(widget.initialKeyword);
  }

  Future<void> _fetchProducts(String keyword) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await ApiSearchService.searchProducts(keyword,1,50);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      _fetchProducts(keyword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        backgroundColor: Colors.redAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _products.isEmpty
          ? const Center(child: Text("Không tìm thấy sản phẩm nào"))
          : GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: (100 / 160),
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: _products[index]);
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _onSearch(),
        decoration: InputDecoration(
          hintText: "Nhập tên sản phẩm...",
          prefixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: _onSearch,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 5),
        ),
      ),
    );
  }
}
