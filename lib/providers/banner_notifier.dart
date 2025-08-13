// lib/providers/banner_notifier.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/models/banner.dart';
import 'package:vegetables_app/services/banner_service.dart';

class BannerNotifier extends StateNotifier<AsyncValue<List<Banner>>> {
  BannerNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchBanners();
  }

  final Ref ref;

  Future<void> fetchBanners() async {
    state = const AsyncValue.loading();
    try {
      final response = await ref.read(bannerServiceProvider).getBanners();

      print(response.data);
      if (response.data['success'] == 'true' && response.data['banners'] != null) {
        final List<dynamic> bannerData = response.data['banners'];
        final banners = bannerData.map((json) => Banner.fromJson(json)).toList();
        state = AsyncValue.data(banners);
      } else {
        // Correctly extract the error message from the response data.
        // Use null-aware operators to safely access nested keys.
        final errorMessage = response.data['message'] ?? response.data['error'] ?? 'Unknown error';

        state = AsyncValue.error(
          'Failed to load banners: $errorMessage',
          StackTrace.current,
        );
      }
    } catch (e, st) {
      // This part is the most critical for handling the 'subtype' error.
      // If 'e' is a DioError and it contains a response, we extract the data safely.
      if (e is DioError && e.response?.data != null) {
        final errorData = e.response!.data;
        final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Unknown API error';
        state = AsyncValue.error(
          'Failed to load banners: $errorMessage',
          st,
        );
      } else {
        // For any other type of error, we use the standard error message.
        state = AsyncValue.error(e, st);
      }
    }
  }
}

final bannerNotifierProvider =
StateNotifierProvider<BannerNotifier, AsyncValue<List<Banner>>>(
      (ref) => BannerNotifier(ref),
);