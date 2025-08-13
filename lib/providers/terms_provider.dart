import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();

final termsProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    throw Exception('Authentication token not found. Please log in.');
  }

  try {
    final response = await dio.get(
      'http://ttbilling.in/vegetable_app/api/terms_conditions.php',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['success'] == 'true') {
        return data['terms_content'];
      } else {
        throw Exception('Failed to load terms: ${data['error'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('Failed to fetch terms. Status code: ${response.statusCode}');
    }
  } on DioException catch (e) {
    print('Dio error (termsProvider): ${e.response?.statusCode} - ${e.response?.data}');
    if (e.response?.statusCode == 401) {
      throw Exception('Unauthorized. Your session may have expired. Please log in again.');
    }
    rethrow;
  } catch (e) {
    print('Error fetching terms: $e');
    rethrow;
  }
});
