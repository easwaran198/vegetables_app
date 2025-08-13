import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:vegetables_app/models/MyOrderRestwo.dart';

enum OrderType { active, completed, cancelled }

// State class to hold the data for our orders screen
class OrderState {
  final List<Cart> orders; // List of fetched orders
  final bool isLoading; // True when data is being fetched
  final String? errorMessage; // Stores error messages if any
  final OrderType selectedType; // Tracks the currently selected order type (tab)

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedType = OrderType.active,
  });

  // Helper method to create a new OrderState with updated values
  OrderState copyWith({
    List<Cart>? orders,
    bool? isLoading,
    String? errorMessage,
    OrderType? selectedType,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

// StateNotifier to manage the OrderState
class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(OrderState()); // Initialize with default state

  // Base URL for your API endpoint
  final String _baseUrl = "http://ttbilling.in/vegetable_app/api/common/my_orders.php";

  // Method to retrieve the authentication token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Method to fetch orders based on the given OrderType
  Future<void> fetchOrders(OrderType type) async {
    // Set loading state and clear previous error/orders
    state = state.copyWith(isLoading: true, errorMessage: null, selectedType: type, orders: []);

    // Convert OrderType enum to the string required by the API
    String typeString;
    switch (type) {
      case OrderType.active:
        typeString = "on process"; // Changed from "active" to "on process" based on API response example
        break;
      case OrderType.completed:
        typeString = "completed";
        break;
      case OrderType.cancelled:
        typeString = "cancelled";
        break;
    }

    try {
      final token = await _getToken(); // Get the token

      if (token == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Authentication token not found. Please log in to view your orders.',
          orders: [],
        );
        return; // Exit if no token
      }

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'token': token, // Add the token to the headers
      };

      // Make the POST request to the API
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers, // Use the headers with the token
        body: jsonEncode({'type': typeString}), // Encode the request body as JSON
      );
      print(Uri.parse(_baseUrl));
      print(jsonEncode({'type': typeString}));
      print(response.body);

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Decode the JSON response body
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        // Parse the JSON into our MyOrdersResponse model
        final myOrdersResponse = MyOrderRestwo.fromJson(jsonResponse);

        // Check the 'success' field from the API response
        if (myOrdersResponse.success == "true") {
          // Update state with fetched orders and turn off loading
          state = state.copyWith(
            orders: myOrdersResponse.cart,
            isLoading: false,
            errorMessage: null,
          );
        } else {
          // If API indicates failure, set error message
          state = state.copyWith(
            isLoading: false,
            errorMessage: myOrdersResponse.message,
            orders: [], // Clear orders on API-level error
          );
        }
      } else if (response.statusCode == 401) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Unauthorized. Your session may have expired. Please log in again.',
          orders: [],
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load orders. Status code: ${response.statusCode}',
          orders: [],
        );
      }
    } catch (e) {
      // Catch any exceptions during the network request or JSON parsing
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error fetching orders: $e',
        orders: [],
      );
    }
  }
}

// Global provider instance for OrderNotifier
final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});
