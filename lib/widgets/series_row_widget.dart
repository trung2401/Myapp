import 'package:flutter/material.dart';
import '../model/category.dart';
import '../services/api_category_service.dart';

class SeriesRowWidget extends StatefulWidget {
  final String brandSlug;
  final Function(Category) onSelect;

  const SeriesRowWidget({
    super.key,
    required this.brandSlug,
    required this.onSelect,
  });

  @override
  State<SeriesRowWidget> createState() => _SeriesRowWidgetState();
}

class _SeriesRowWidgetState extends State<SeriesRowWidget> {
  List<Category> seriesList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries() async {

    try {
      final fetched = await CategoryApiService().fetchSeriesByBrand(widget.brandSlug);
      print("🔹 Gọi API series với brandSlug: ${widget.brandSlug}");
      setState(() {
        seriesList = fetched;
        isLoading = false;
      });
      print("❌ Không có dòng series nào");
    } catch (e) {
      print("❌ Lỗi khi tải series: $e");
      setState(() => isLoading = false);

    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (seriesList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(1),
        // child: Text("Không có dòng series nào."),

      );
    }

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: seriesList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final series = seriesList[index];
          return GestureDetector(
            onTap: () => widget.onSelect(series),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  series.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
