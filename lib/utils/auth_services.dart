import 'package:dio/dio.dart';

class AuthService {
  final Dio dio;
  AuthService(this.dio);

  Future<Response> register(Map<String, dynamic> data) =>
      dio.post('/register', data: data);

  Future<Response> verifyOtp(Map<String, dynamic> data) =>
      dio.post('/verifyotp', data: data);

  Future<Response> getProfile() =>
      dio.get('/my-profile');
}
