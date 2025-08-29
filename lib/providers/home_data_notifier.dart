import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:vegetables_app/models/product.dart';
import 'package:vegetables_app/models/offer_product.dart';
import 'package:vegetables_app/models/banner.dart';
import 'package:vegetables_app/models/category_res.dart';
import 'package:vegetables_app/services/product_service.dart';
import 'package:vegetables_app/services/banner_service.dart';

/// 🔹 Product List Notifier
class ProductListNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductListNotifier(this.ref, this.categoryId) : super(const AsyncValue.loading()) {
    fetchProducts();
  }

  final Ref ref;
  final String categoryId;

  Future<void> fetchProducts() async {
    state = const AsyncValue.loading();
    try {
      final qparams = {
        "category": categoryId,
        "offer": "",
        "page": 1,
        "limit": 10,
        "search_keyword" : ""
      };
      final response = await ref.read(productServiceProvider).getProducts(params: qparams);

      if (response.data['success'] == 'true' && response.data['product'] != null) {

        final products = (response.data['product'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        state = AsyncValue.data(products);
      } else {
        final errorMessage = response.data['message'] ?? 'Unknown error';
        state = AsyncValue.error('Failed to load products: $errorMessage', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Provider with family
final productListNotifierProvider = StateNotifierProvider.family<
    ProductListNotifier, AsyncValue<List<Product>>, String>((ref, categoryId) {
  return ProductListNotifier(ref, categoryId);
});



/// 🔹 Wish List Notifier
class WishListNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  WishListNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchProducts();
  }

  final Ref ref;

  Future<void> fetchProducts() async {
    state = const AsyncValue.loading();
    try {
      final response = await ref.read(productServiceProvider).getWishList();

      if (response.data['success'] == 'true' && response.data['product'] != null) {

        final products = (response.data['product'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        state = AsyncValue.data(products);
      } else {
        final errorMessage = response.data['message'] ?? 'Unknown error';
        state = AsyncValue.error('Failed to load products: $errorMessage', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}


final wishListNotifierProvider =
StateNotifierProvider<WishListNotifier, AsyncValue<List<Product>>>(
        (ref) => WishListNotifier(ref));



/// 🔹 Offer Product Notifier
class OfferProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  OfferProductNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchOfferProducts();
  }

  final Ref ref;

  Future<void> fetchOfferProducts() async {
    state = const AsyncValue.loading();
    try {
      final qparams = {
        "category":"",
        "offer":"1",
        "page": 1,
        "limit": 100
      };

      final response = await ref.read(productServiceProvider).getOfferProducts(params: qparams);

      if (response.data['success'] == 'true' && response.data['product'] != null) {
        final products = (response.data['product'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        state = AsyncValue.data(products);
      } else {
        final errorMessage = response.data['message'] ?? 'Unknown error';
        state = AsyncValue.error('Failed to load offer products: $errorMessage', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final offerProductNotifierProvider =
StateNotifierProvider<OfferProductNotifier, AsyncValue<List<Product>>>(
        (ref) => OfferProductNotifier(ref));

/// 🔹 Banner Notifier
class BannerNotifier extends StateNotifier<AsyncValue<List<Banner>>> {
  BannerNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchBanners();
  }

  final Ref ref;

  Future<void> fetchBanners() async {
    state = const AsyncValue.loading();
    try {
      final response = await ref.read(bannerServiceProvider).getBanners();

      if (response.data['success'] == 'true' && response.data['banners'] != null) {
        final banners = (response.data['banners'] as List)
            .map((json) => Banner.fromJson(json))
            .toList();
        state = AsyncValue.data(banners);
      } else {
        final errorMessage = response.data['message'] ?? response.data['error'] ?? 'Unknown error';
        state = AsyncValue.error('Failed to load banners: $errorMessage', StackTrace.current);
      }
    } catch (e, st) {
      if (e is DioError && e.response?.data != null) {
        final errorMessage = e.response!.data['message'] ?? e.response!.data['error'] ?? 'Unknown API error';
        state = AsyncValue.error('Failed to load banners: $errorMessage', st);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }
}

final bannerNotifierProvider =
StateNotifierProvider<BannerNotifier, AsyncValue<List<Banner>>>(
        (ref) => BannerNotifier(ref));

/// 🔹 Category Notifier
class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  CategoryNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchCategories();
  }

  final Ref ref;

  Future<void> fetchCategories() async {
    state = const AsyncValue.loading();
    try {
      final response = await ref.read(productServiceProvider).getCategories();

      print(response.data);
      print(response.data['success'] == 'true');
      print(response.data['category'] != null);
      if (response.data['success'] == 'true' && response.data['category'] != null) {
        print("esaaa");

        final categories = (response.data['category'] as List)
            .map((json) => Category.fromJson(json))
            .toList();
        state = AsyncValue.data(categories);
      } else {
        final errorMessage = response.data['message'] ?? 'Unknown error';
        state = AsyncValue.error('Failed to load categories: $errorMessage', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final categoryNotifierProvider =
StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>(
        (ref) => CategoryNotifier(ref));

class FrequentOrderNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  FrequentOrderNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchFrequentOrders();
  }

  final Ref ref;

  Future<void> fetchFrequentOrders() async {
    state = const AsyncValue.loading();
    try {
      final response = await ref.read(productServiceProvider).getFrequentOrders();
      final data = response.data;

      print('Raw frequent orders response: $data');

      if (data['success'] == 'true' && data['products'] != null) {
        final products = (response.data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();

        state = AsyncValue.data(products);


      } else {
        // Return empty list instead of throwing error
        state = AsyncValue.data([]);
      }

    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final frequentOrderNotifierProvider =
StateNotifierProvider<FrequentOrderNotifier, AsyncValue<List<Product>>>(
      (ref) => FrequentOrderNotifier(ref),
);
