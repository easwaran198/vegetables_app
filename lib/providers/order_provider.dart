import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegetables_app/models/MyOrderRestwo.dart';

enum OrderType { active, completed, cancelled }

// Order State for listing orders
class OrderState {
  final List<Orders> orders;
  final bool isLoading;
  final String? errorMessage;
  final OrderType selectedType;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedType = OrderType.active,
  });

  OrderState copyWith({
    List<Orders>? orders,
    bool? isLoading,
    String? errorMessage,
    OrderType? selectedType,
    bool clearError = false,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

// Order Details State for individual order details
class OrderDetailsState {
  final OrderDetailsModel? orderDetails;
  final bool isLoading;
  final String? errorMessage;

  OrderDetailsState({
    this.orderDetails,
    this.isLoading = false,
    this.errorMessage,
  });

  OrderDetailsState copyWith({
    OrderDetailsModel? orderDetails,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearOrderDetails = false,
  }) {
    return OrderDetailsState(
      orderDetails: clearOrderDetails ? null : (orderDetails ?? this.orderDetails),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// Main Order Notifier for order listing
class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(OrderState());

  final String _baseUrl = "https://kaaivandi.com/api/myorder";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Method to fetch orders based on the given OrderType
  Future<void> fetchOrders(OrderType type) async {
    // Set loading and selected type, clear previous error
    state = state.copyWith(
        isLoading: true,
        selectedType: type,
        clearError: true
    );

    // Convert OrderType enum to the string required by the API
    String typeString;
    switch (type) {
      case OrderType.active:
        typeString = "on process";
        break;
      case OrderType.completed:
        typeString = "completed";
        break;
      case OrderType.cancelled:
        typeString = "cancelled";
        break;
    }

    try {
      final token = await _getToken();

      if (token == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Authentication token not found. Please log in to view your orders.',
          orders: [],
        );
        return;
      }

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'token': token,
      };


      // Make the POST request to the API
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: jsonEncode({'type': typeString}),
      );

      print('Orders API URL: ${Uri.parse(_baseUrl)}');
      print('Orders Request Body: ${jsonEncode({'type': typeString})}');
      print('Orders Response Status: ${response.statusCode}');
      print('Orders Response Body: ${response.body}');

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
            orders: myOrdersResponse.orders ?? [],
            isLoading: false,
            errorMessage: null,
          );
        } else {
          // If API indicates failure, set error message
          state = state.copyWith(
            isLoading: false,
            errorMessage: myOrdersResponse.message ?? 'Failed to fetch orders',
            orders: [],
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
      print('Error in fetchOrders: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error fetching orders: $e',
        orders: [],
      );
    }
  }

  // Method to refresh current orders
  void refreshCurrentOrders() {
    fetchOrders(state.selectedType);
  }

  // Method to clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Order Details Notifier for individual order details
class OrderDetailsNotifier extends StateNotifier<OrderDetailsState> {
  OrderDetailsNotifier() : super(OrderDetailsState());

  final String _orderDetailsUrl = "https://kaaivandi.com/api/order_details";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Method to fetch order details by order ID
  Future<void> fetchOrderDetails(int orderId) async {
    // Set loading state and clear previous data
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearOrderDetails: true,
    );

    try {
      final token = await _getToken();

      if (token == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Authentication token not found. Please log in again.',
        );
        return;
      }

      final Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'token': token,
      };

      print('Order Details API URL: $_orderDetailsUrl');
      print('Order Details Request: orderid=$orderId');
      print('Using token: $token');

      final Map<String, dynamic> body = {'orderid': orderId};

      final response = await http.post(
        Uri.parse(_orderDetailsUrl),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: json.encode(body),
      );



      print('Order Details Response Status: ${response.statusCode}');
      print('Order Details Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == 'true') {
          final orderDetails = OrderDetailsModel.fromJson(jsonData);
          state = state.copyWith(
            orderDetails: orderDetails,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: jsonData['message'] ?? 'Failed to fetch order details',
          );
        }
      } else if (response.statusCode == 401) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Unauthorized. Your session may have expired. Please log in again.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in fetchOrderDetails: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error: ${e.toString()}',
      );
    }
  }

  // Method to retry fetching order details
  void retryFetchOrderDetails(int orderId) {
    fetchOrderDetails(orderId);
  }

  // Method to clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Method to clear order details (useful when navigating away)
  void clearOrderDetails() {
    state = state.copyWith(clearOrderDetails: true, clearError: true);
  }
}

class OrderDetailsModel {
  String? success;
  String? error;
  String? message;
  int? orderId;
  String? orderNo;
  String? orderDate;
  String? orderTime;
  String? totalAmount;
  String? orderStatus;
  int? productCount;
  List<Products>? products;

  OrderDetailsModel(
      {this.success,
        this.error,
        this.message,
        this.orderId,
        this.orderNo,
        this.orderDate,
        this.orderTime,
        this.totalAmount,
        this.orderStatus,
        this.productCount,
        this.products});

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    orderId = json['order_id'];
    orderNo = json['order_no'];
    orderDate = json['order_date'];
    orderTime = json['order_time'];
    totalAmount = json['total_amount'];
    orderStatus = json['order_status'];
    productCount = json['product_count'];
    if (json['orders'] != null) {
      products = <Products>[];
      json['orders'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['error'] = this.error;
    data['message'] = this.message;
    data['order_id'] = this.orderId;
    data['order_no'] = this.orderNo;
    data['order_date'] = this.orderDate;
    data['order_time'] = this.orderTime;
    data['total_amount'] = this.totalAmount;
    data['order_status'] = this.orderStatus;
    data['product_count'] = this.productCount;
    if (this.products != null) {
      data['orders'] = this.products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  String? id;
  String? name;
  String? unit;
  String? price;
  int? qty;
  String? total;
  String? max;
  String? rating;
  String? tamilName;
  int? wishcount;
  String? productBenefits;
  List<Images>? images;

  Products(
      {this.id,
        this.name,
        this.unit,
        this.price,
        this.qty,
        this.total,
        this.max,
        this.rating,
        this.tamilName,
        this.wishcount,
        this.productBenefits,
        this.images});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    unit = json['unit'];
    price = json['price'];
    qty = json['qty'];
    total = json['total'];
    max = json['max'];
    rating = json['rating'];
    tamilName = json['tamil_name'];
    wishcount = json['wishcount'];
    productBenefits = json['product_benefits'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['unit'] = this.unit;
    data['price'] = this.price;
    data['qty'] = this.qty;
    data['total'] = this.total;
    data['max'] = this.max;
    data['rating'] = this.rating;
    data['tamil_name'] = this.tamilName;
    data['wishcount'] = this.wishcount;
    data['product_benefits'] = this.productBenefits;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Images {
  String? image;

  Images({this.image});

  Images.fromJson(Map<String, dynamic> json) {
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    return data;
  }
}



// Global provider instances
final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});

final orderDetailsProvider = StateNotifierProvider<OrderDetailsNotifier, OrderDetailsState>((ref) {
  return OrderDetailsNotifier();
});