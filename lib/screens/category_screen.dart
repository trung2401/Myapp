import 'package:flutter/material.dart';
import '../model/category.dart' as myCat;
import '../pages/list_product_page.dart';
import '../services/api_category_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<myCat.Category> mainCategories = [];
  String? selectedSlug;
  late Future<List<myCat.Category>> subCategoriesFuture;
  late Future<List<myCat.Category>> featureCategoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadMainCategories();
  }

  Future<void> _loadMainCategories() async {
    final categories = await CategoryApiService().fetchCategories();
    if (categories.isNotEmpty) {
      setState(() {
        mainCategories = categories;
        selectedSlug = categories.first.slug;
        subCategoriesFuture = CategoryApiService().fetchSubCategories(selectedSlug!);
        featureCategoriesFuture = CategoryApiService().fetchFeatureCategories(selectedSlug!);
      });
    }
  }

  void _onSelectCategory(String slug) {
    setState(() {
      selectedSlug = slug;
      subCategoriesFuture = CategoryApiService().fetchSubCategories(slug);
      featureCategoriesFuture = CategoryApiService().fetchFeatureCategories(slug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mainCategories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Row(
        children: [
          // 🔹 CỘT TRÁI: Danh mục chính
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: mainCategories.length,
              itemBuilder: (context, index) {
                final cat = mainCategories[index];
                final isSelected = selectedSlug == cat.slug;

                return GestureDetector(
                  onTap: () => _onSelectCategory(cat.slug),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: Image.network(
                            cat.fullLogoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 40),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔹 CỘT PHẢI: Brand + Feature
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ======= THƯƠNG HIỆU =======
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Thương hiệu",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  FutureBuilder<List<myCat.Category>>(
                    future: subCategoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ));
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Lỗi: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("Không có thương hiệu"));
                      } else {
                        final subCategories = snapshot.data!;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2 / 1,
                          ),
                          itemCount: subCategories.length,
                          itemBuilder: (context, index) {
                            final subCat = subCategories[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ListProductPage(category: subCat),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                  Border.all(color: Colors.grey.shade300),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(
                                    subCat.fullLogoUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image,
                                        size: 40),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),

                  // ======= TÍNH NĂNG =======
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Tính năng",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  FutureBuilder<List<myCat.Category>>(
                    future: featureCategoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ));
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Lỗi: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("Không có tính năng"));
                      } else {
                        final features = snapshot.data!;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // ít cột hơn cho text dài
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 3 / 1,
                          ),
                          itemCount: features.length,
                          itemBuilder: (context, index) {
                            final feature = features[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ListProductPage(category: feature),
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                  Border.all(color: Colors.grey.shade300),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    feature.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
