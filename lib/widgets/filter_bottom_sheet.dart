import 'package:flutter/material.dart';
import '../model/attribute_filter.dart';
import '../services/api_get_attribute_filter_service.dart';

/// Hàm hiển thị Bottom Sheet bộ lọc
Future<Map<String, dynamic>?> showFilterBottomSheet(
    BuildContext context, String categorySlug) async {
  return await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return FilterBottomSheet(categorySlug: categorySlug);
    },
  );
}

/// Widget hiển thị nội dung bộ lọc
class FilterBottomSheet extends StatefulWidget {
  final String categorySlug;
  const FilterBottomSheet({super.key, required this.categorySlug});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  List<AttributeFilter> filters = [];
  Map<String, String> selectedFilters = {}; // code: value
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    try {
      final fetchedFilters =
      await AttributeFilterApiService.fetchFiltersBySlug(widget.categorySlug);
      setState(() {
        filters = fetchedFilters;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải bộ lọc: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: screenHeight * 0.85, // 🔹 85% chiều cao màn hình
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Thanh tiêu đề ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.3),
                ),
              ),
              child: const Text(
                "Bộ lọc",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  return _buildFilterSection(filter);
                },
              ),
            ),

            // --- Nút Áp dụng ---
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -1),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedFilters.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text("Thiết lập lại"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, selectedFilters);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Áp dụng"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(AttributeFilter filter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filter.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filter.values.map((value) {
            final isSelected = selectedFilters[filter.code] == value.value;
            return ChoiceChip(
              label: Text(value.label),
              selected: isSelected,
              selectedColor: Colors.redAccent.shade100,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedFilters[filter.code] = value.value;
                  } else {
                    selectedFilters.remove(filter.code);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
