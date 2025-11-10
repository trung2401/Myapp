import 'package:flutter/material.dart';
import 'package:myapp/model/store.dart';
import 'package:myapp/services/api_store_service.dart';

class StoreCardRow extends StatefulWidget {
  const StoreCardRow({super.key});

  @override
  State<StoreCardRow> createState() => _StoreCardRowState();
}

class _StoreCardRowState extends State<StoreCardRow> {
  final ApiStoreService _storeService = ApiStoreService();
  late Future<List<Store>> _futureStores;

  @override
  void initState() {
    super.initState();
    _futureStores = _storeService.fetchStores();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Store>>(
      future: _futureStores,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi tải cửa hàng: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Không có cửa hàng nào.'),
          );
        }

        final stores = snapshot.data!;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: stores.map((store) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Card(
                  elevation: 3,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          store.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          store.displayAddress,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "🕗 ${store.timeOpen}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "- ${store.timeClose}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
