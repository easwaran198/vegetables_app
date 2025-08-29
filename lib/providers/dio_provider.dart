// lib/providers/dio_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/utils/token_interceptor.dart'; // Import your interceptor

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
   // baseUrl: 'https://kaaivandi.com/api/',
    baseUrl: 'https://kaaivandi.com/api/',
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Add the custom interceptor to the Dio instance.
  dio.interceptors.add(TokenInterceptor());

  return dio;
});