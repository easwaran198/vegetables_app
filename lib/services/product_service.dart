import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegetables_app/providers/dio_provider.dart';

class ProductService {
  final Dio _dio;

  ProductService(this._dio);

  Future<Response> getProducts({Map<String, dynamic>? params}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    try {
      final response = await _dio.get(
        'http://ttbilling.in/vegetable_app/api/product_list',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'token': token,
          },
        ),
        queryParameters: params, // Add this line
      );
      return response;
    } on DioException catch (e) {
      print('Dio error (getProducts): ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Your session may have expired. Please log in again.');
      }
      rethrow;
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  // New method for fetching offer products
  Future<Response> getOfferProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    try {
      final response = await _dio.get(
        'http://ttbilling.in/vegetable_app/api/offer_products', // Assuming this is your offer products API endpoint
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'token': token,
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      print('Dio error (getOfferProducts): ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Your session may have expired. Please log in again.');
      }
      rethrow;
    } catch (e) {
      print('Error fetching offer products: $e');
      rethrow;
    }
  }
}

// Riverpod Provider for ProductService (remains the same)
final productServiceProvider = Provider<ProductService>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductService(dio);
});