import 'dart:convert';
import 'package:flutter/material.dart'; // Import for BuildContext and SnackBar
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegetables_app/models/profile_model.dart'; // Make sure this path is correct


const String myProfileApiUrl = 'http://ttbilling.in/vegetable_app/api/common/my_profile.php';
const String updateProfileApiUrl = 'https://ttbilling.in/vegetable_app/api/editprofile'; // Placeholder URL

class ProfileService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<int?> _getUserid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<Profile> fetchProfile() async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'token': token, // Add the token to the header
      };

      final response = await http.get(
        Uri.parse(myProfileApiUrl),
        headers: headers,
      );

      print("Profile API Request URL: $myProfileApiUrl");
      print("Profile API Request Headers: $headers");
      print("Profile API Response Status Code: ${response.statusCode}");
      print("Profile API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == 'true') {
          return Profile.fromJson(data);
        } else {
          throw Exception('API Error: ${data['message'] ?? 'Failed to load profile.'}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Your session may have expired. Please log in again.');
      } else {
        throw Exception('Failed to load profile: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      rethrow;
    }
  }


  Future<void> updateProfile({
    required BuildContext context,
    required String name,
    required String mail,
    String? address,
    String? profileimg,
    required String mobileno,
  }) async {
    final token = await _getToken();
    final userid = await _getUserid();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found. Please log in to update your profile.'), duration: Duration(seconds: 3)),
      );
      return; // Exit if no token
    }

    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'token': token,
      };

      final Map<String, dynamic> requestBody = {
        "userid": userid.toString(),
        "name": name,
        "mobileno": mobileno,
        "emailid": mail,
      };

      if (address != null && address.isNotEmpty) {
        requestBody["address"] = address;
      } else {
        requestBody["address"] = null; // Or omit if your API doesn't require sending null
      }

      if (profileimg != null && profileimg.isNotEmpty) {
        requestBody["profileimg"] = profileimg;
      }

      final body = json.encode(requestBody);

      final response = await http.post(
        Uri.parse(updateProfileApiUrl),
        headers: headers,
        body: body,
      );

      print("Update Profile API Request URL: $updateProfileApiUrl");
      print("Update Profile API Request Headers: $headers");
      print("Update Profile API Request Body: $body");
      print("Update Profile API Response Status Code: ${response.statusCode}");
      print("Update Profile API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == 'true') {
          // Use the passed context to show the SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'].toString()), duration: const Duration(seconds: 1)),
          );
          // You might also want to return the updated Profile object if your API sends it back
          // For now, we'll just indicate success by showing the SnackBar.
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Failed to update profile.'), duration: const Duration(seconds: 3)),
          );
          // throw Exception('API Error: ${data['message'] ?? 'Failed to update profile.'}');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: HTTP ${response.statusCode} - ${response.body}'), duration: const Duration(seconds: 3)),
        );
        // throw Exception('Failed to update profile: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), duration: const Duration(seconds: 3)),
      );
      // rethrow; // You might not want to rethrow if you're handling all errors with SnackBars
    }
  }
}