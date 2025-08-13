import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegetables_app/providers/dio_provider.dart';
import 'package:vegetables_app/utils/auth_services.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});


class VerifyotpNotifier extends StateNotifier<AsyncValue<Response>> {
  VerifyotpNotifier(this.ref) : super(const AsyncValue.loading());
  final Ref ref;

  Future<void> verifyOtp(Map<String, dynamic> data) async {
    try {
      final response = await ref.read(authServiceProvider).verifyOtp(data);
      state = AsyncValue.data(response);

      print(response);
      // Extract token and userId from response
      final responseData = response.data;
      final token = responseData['token'];
      final userId = responseData['userid']; // Adjust based on your actual response structure

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setInt('userId', userId);

      print('Saved token: $token, userId: $userId');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

}

final verifyotpNotifier =
StateNotifierProvider<VerifyotpNotifier, AsyncValue<Response>>(
        (ref) => VerifyotpNotifier(ref));
