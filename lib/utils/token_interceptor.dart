// lib/utils/token_interceptor.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Await SharedPreferences to get the token.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // If a token exists, add it to the Authorization header.
    if (token != null) {
      options.headers['token'] = '$token';
    }

    // Continue with the request.
    super.onRequest(options, handler);
  }
}