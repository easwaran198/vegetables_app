import 'dart:convert';

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
      print('Sending POST request with params: ${json.encode(params)}');

      final response = await _dio.post(
        'https://kaaivandi.com/api/product_list',
        data: params, // Send parameters in request body
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'token': token,
          },
        ),
      );

      print('Request URL: ${response.requestOptions.uri}');
      print('Request data: ${json.encode(response.requestOptions.data)}');

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
  Future<Response> getWishList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    try {

      final response = await _dio.post(
        'https://kaaivandi.com/api/wishlist',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'token': token,
          },
        ),
      );

      print('Request URL: ${response.requestOptions.uri}');
      print(response);

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

  Future<Response> getProducts2({Map<String, dynamic>? params}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    try {
      final response = await _dio.get(
        'https://kaaivandi.com/api/product_list',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'token': token,
          },
        ),
        queryParameters: params,
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
  Future<Response> getOfferProducts({Map<String, dynamic>? params}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    try {
      final response = await _dio.get(
        'https://kaaivandi.com/api/product_list',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'token': token,
          },
        ),
        queryParameters: params, // Add this line
      );
      print("https://kaaivandi.com/api/product_list");
      //print(json.encode(response));
      print("offerlist : "+response.toString());
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
  Future<Response> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    try {
      final response = await _dio.get(
        'https://kaaivandi.com/api/category',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'token': token,
          },
        )
      );
      print("https://kaaivandi.com/api/category");
      //print(json.encode(response));
      print(response);
      return response;
    } on DioException catch (e) {
      print('Dio error (fetchCategories): ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Your session may have expired. Please log in again.');
      }
      rethrow;
    } catch (e) {
      print('Error fetching fetchCategories: $e');
      rethrow;
    }
  }
  Future<Response> getFrequentOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    try {
      final response = await _dio.get(
        'https://kaaivandi.com/api/frequent',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'token': token,
          },
        )
      );
      print("https://kaaivandi.com/api/frequent");
      //print(json.encode(response));
      print(response);
      return response;
    } on DioException catch (e) {
      print('Dio error (getFrequentOrders): ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Your session may have expired. Please log in again.');
      }
      rethrow;
    } catch (e) {
      print('Error fetching getFrequentOrders: $e');
      rethrow;
    }
  }

 /* // New method for fetching offer products
  Future<Response> getOfferProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    try {
      final response = await _dio.get(
        'https://kaaivandi.com/api/offer_products', // Assuming this is your offer products API endpoint
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
  }*/
}

final productServiceProvider = Provider<ProductService>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductService(dio);
});