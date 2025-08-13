import 'dart:convert'; // For json.decode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart' as dio; // Assuming you are using Dio for networking
// Make sure to import your RegisterResData model
import 'package:vegetables_app/models/register_res_data.dart';
import 'package:vegetables_app/providers/verifyotp_notifier.dart';
// Also import your authServiceProvider if it's in a separate file
// import 'package:vegetables_app/services/auth_service_provider.dart'; // Example import


// Define your provider. Assuming StateNotifierProvider for this example.
// Ensure the generic type is AsyncValue<RegisterResData>
final registerProvider = StateNotifierProvider<RegisterNotifier, AsyncValue<RegisterResData>>(
      (ref) => RegisterNotifier(ref),
);

class RegisterNotifier extends StateNotifier<AsyncValue<RegisterResData>> {
  final Ref ref;

  RegisterNotifier(this.ref) : super(AsyncValue.data(RegisterResData())); // Initial state

  Future<void> registerUser(Map<String, dynamic> data) async {
    // Set state to loading while the operation is in progress
    state = const AsyncValue.loading();

    print(data);
    print(data);

    try {
      // 1. Make the API call. This returns a dio.Response<dynamic>.
      // The type of 'response' here is 'dio.Response<dynamic>'.
      final dio.Response<dynamic> apiResponse = await ref.read(authServiceProvider).register(data);

      RegisterResData registerResData;
      print(apiResponse);

      // 2. Check the API response status and data format
      if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
        // Assuming the actual JSON data is in apiResponse.data
        if (apiResponse.data is Map<String, dynamic>) {
          // Parse the Map<String, dynamic> directly into RegisterResData
          registerResData = RegisterResData.fromJson(apiResponse.data);
        } else if (apiResponse.data is String) {
          // If the API returns a raw JSON string, decode it first
          final Map<String, dynamic> decodedData = json.decode(apiResponse.data);
          registerResData = RegisterResData.fromJson(decodedData);
        } else {
          // Handle unexpected data type from API response.
          // This means the 'data' field of the Dio response was neither a Map nor a String.
          throw Exception("Unexpected data format from API: ${apiResponse.data.runtimeType}");
        }
      } else {
        // Handle non-2xx status codes (e.g., 400, 401, 500)
        // Try to extract an error message from the response body if available
        String errorMessage = 'Server error: ${apiResponse.statusCode}';
        if (apiResponse.data is Map<String, dynamic> && apiResponse.data.containsKey('message')) {
          errorMessage = apiResponse.data['message'];
        } else if (apiResponse.data is String) {
          try {
            final Map<String, dynamic> errorBody = json.decode(apiResponse.data);
            errorMessage = errorBody['message'] ?? errorMessage;
          } catch (e) {
            // Ignore if not a valid JSON string
          }
        }
        throw Exception(errorMessage); // Throw an exception to be caught below
      }

      // 3. Update the state with the correctly parsed RegisterResData object
      // This is the crucial line that prevents the type error in your UI.
      state = AsyncValue.data(registerResData);
      print("Register success state updated with: $registerResData");

    } on dio.DioException catch (e) { // Catch Dio-specific errors (network issues, timeouts)
      String errorMessage = 'Network error during registration.';
      if (e.response != null) {
        // Server responded with an error (e.g., 4xx, 5xx)
        // Try to get a specific message from the error response body
        if (e.response!.data is Map<String, dynamic> && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        } else {
          errorMessage = e.response!.statusMessage ?? 'Server responded with an error.';
        }
      } else {
        // Request failed without a response (e.g., no internet, DNS error)
        errorMessage = e.message ?? 'Connection error during registration.';
      }
      state = AsyncValue.error(errorMessage, StackTrace.current);
      print("Dio error: $e, Stack: ${StackTrace.current}");

    } catch (e, st) {
      // Catch any other general exceptions (e.g., parsing errors, custom service exceptions)
      state = AsyncValue.error(e, st);
      print("General error: $e, Stack: $st");
    }
  }
}