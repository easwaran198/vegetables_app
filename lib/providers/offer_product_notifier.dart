// lib/providers/offer_product_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:vegetables_app/models/offer_product.dart';
import 'package:vegetables_app/services/product_service.dart'; // Import your ProductService

class OfferProductNotifier extends StateNotifier<AsyncValue<List<OfferProduct>>> {
  OfferProductNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchOfferProducts();
  }

  final Ref ref;

  Future<void> fetchOfferProducts() async {
    state = const AsyncValue.loading();
    try {
      final response = await ref.read(productServiceProvider).getOfferProducts();

      if (response.data['success'] == 'true' && response.data['product'] != null) {
        final List<dynamic> productData = response.data['product'];
        final products = productData.map((json) => OfferProduct.fromJson(json)).toList();
        state = AsyncValue.data(products);
      } else {
        state = AsyncValue.error(
            'Failed to load offer products: ${response.data['messgae'] ?? 'Unknown error'}',
            StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final offerProductNotifierProvider =
StateNotifierProvider<OfferProductNotifier, AsyncValue<List<OfferProduct>>>(
      (ref) => OfferProductNotifier(ref),
);