// lib/providers/product_list_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:vegetables_app/models/product.dart'; // Import your Product model
import 'package:vegetables_app/services/product_service.dart'; // Import your ProductService
import 'package:vegetables_app/providers/dio_provider.dart'; // Assuming dioProvider is here

class ProductListNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductListNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchProducts();
  }

  final Ref ref;

  Future<void> fetchProducts() async {
    state = const AsyncValue.loading();
    try {
      final response = await ref.read(productServiceProvider).getProducts();

      if (response.data['success'] == 'true' && response.data['product'] != null) {
        final List<dynamic> productData = response.data['product'];
        final products = productData.map((json) => Product.fromJson(json)).toList();
        state = AsyncValue.data(products);
      } else {
        state = AsyncValue.error(
            'Failed to load products: ${response.data['messgae'] ?? 'Unknown error'}',
            StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final productListNotifierProvider =
StateNotifierProvider<ProductListNotifier, AsyncValue<List<Product>>>(
      (ref) => ProductListNotifier(ref),
);