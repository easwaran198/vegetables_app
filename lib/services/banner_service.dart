// lib/services/banner_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/providers/dio_provider.dart';

class BannerService {
  final Dio _dio;

  BannerService(this._dio);

  Future<Response> getBanners() async {
    return await _dio.get('https://kaaivandi.com/api/common/banner.php');
  }
}

final bannerServiceProvider = Provider<BannerService>((ref) {
  final dio = ref.watch(dioProvider);
  return BannerService(dio);
});