import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegetables_app/models/cart.dart';

const String cartListApiUrl = 'https://kaaivandi.com/api/cart_list';
const String addToCartApiUrl = 'https://kaaivandi.com/api/add_to_cart';
const String addToWishlistApiUrl = 'https://kaaivandi.com/api/addwish';
const String deleteCartApiUrl = 'https://kaaivandi.com/api/common/delete_cart.php';
const String placeOrderApiUrl = 'https://kaaivandi.com/api/common/place_order.php'; // New API URL

class CartService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming you store the user ID in SharedPreferences upon login
    return prefs.getInt('userId');
  }

  Future<CartResponse> fetchCartList() async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Authentication token not found. Please log in to view your cart.');
    }

    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'token': token,
      };

      final response = await http.get(
        Uri.parse(cartListApiUrl),
        headers: headers,
      );

      print("Cart API Request URL: $cartListApiUrl");
      print("Cart API Request Headers: $headers");
      print("Cart API Response Status Code: ${response.statusCode}");
      print("Cart API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == 'false' && data['error'] == 'true') {
          throw Exception('API Error: ${data['message']}');
        }

        return CartResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Your session may have expired. Please log in again.');
      } else {
        throw Exception('Failed to load cart: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching cart: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addToCart(String productId, int quantity) async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Authentication token not found. Please log in to add items to your cart.');
    }

    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'token': token,
      };

      final body = json.encode({
        "product_id": productId,
        "quantity": quantity.toString(), // API expects string for quantity
      });

      final response = await http.post(
        Uri.parse(addToCartApiUrl),
        headers: headers,
        body: body,
      );

      print("Add to Cart API Request URL: $addToCartApiUrl");
      print("Add to Cart API Request Headers: $headers");
      print("Add to Cart API Request Body: $body");
      print("Add to Cart API Response Status Code: ${response.statusCode}");
      print("Add to Cart API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == 'true') {
          return data;
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to add to cart: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }
  Future<Map<String, dynamic>> addToWishlist(String productId, int status) async {

    final token = await _getToken();

    if (token == null) {
      throw Exception('Authentication token not found. Please log in to add items to your cart.');
    }

    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'token': token,
      };

      final body = json.encode({
        "productid": productId,
        "fav": status.toString(), // API expects string for quantity
      });

      final response = await http.post(
        Uri.parse(addToWishlistApiUrl),
        headers: headers,
        body: body,
      );

      print("Add to Cart API Request URL: $addToWishlistApiUrl");
      print("Add to Cart API Request Headers: $headers");
      print("Add to Cart API Request Body: $body");
      print("Add to Cart API Response Status Code: ${response.statusCode}");
      print("Add to Cart API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == 'true') {
          return data;
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to addToWishlistApi: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error adding addToWishlistApi: $e');
      rethrow;
    }
  }

  // New method to delete item from cart
  Future<Map<String, dynamic>> deleteCartItem(String productId) async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Authentication token not found. Please log in to remove items from your cart.');
    }

    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'token': token,
      };

      final body = json.encode({
        "product_id": productId,
      });

      final response = await http.post(
        Uri.parse(deleteCartApiUrl),
        headers: headers,
        body: body,
      );

      print("Delete Cart API Request URL: $deleteCartApiUrl");
      print("Delete Cart API Request Headers: $headers");
      print("Delete Cart API Request Body: $body");
      print("Delete Cart API Response Status Code: ${response.statusCode}");
      print("Delete Cart API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == 'true') {
          return data;
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to delete from cart: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error deleting from cart: $e');
      rethrow;
    }
  }

  // New method to place an order
  Future<Map<String, dynamic>> placeOrder(String paymentMode, String grandTotal, String deliveryStatus) async {    final token = await _getToken();
    final userId = await _getUserId();

    if (token == null || userId == null) {
      throw Exception('Authentication token or User ID not found. Please log in to place an order.');
    }

    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'token': token,
      };


      final body = json.encode({
        "user_id": userId.toString(),
        "payment_mode": paymentMode,
        "subtotal": grandTotal,
        "delivery_status": deliveryStatus,
      });

      final response = await http.post(
        Uri.parse(placeOrderApiUrl),
        headers: headers,
        body: body,
      );

      print("Place Order API Request URL: $placeOrderApiUrl");
      print("Place Order API Request Headers: $headers");
      print("Place Order API Request Body: $body");
      print("Place Order API Response Status Code: ${response.statusCode}");
      print("Place Order API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == 'true') {
          return data;
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to place order: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error placing order: $e');
      rethrow;
    }
  }
}

final cartServiceProvider = Provider((ref) => CartService());

final cartListProvider = FutureProvider<CartResponse>((ref) async {
  final cartService = ref.watch(cartServiceProvider);
  return cartService.fetchCartList();
});

final cartItemQuantitiesProvider = StateNotifierProvider<CartItemQuantitiesNotifier, Map<String, int>>((ref) {
  return CartItemQuantitiesNotifier();
});

class CartItemQuantitiesNotifier extends StateNotifier<Map<String, int>> {
  CartItemQuantitiesNotifier() : super({});

  void setInitialQuantities(List<CartItem> items) {
    state = {for (var item in items) item.productId: int.tryParse(item.qty) ?? 0};
  }

  void incrementQuantity(String productId) {
    state = {
      ...state,
      productId: (state[productId] ?? 0) + 1,
    };
  }

  void decrementQuantity(String productId) {
    state = {
      ...state,
      productId: (state[productId] ?? 0) > 1 ? (state[productId] ?? 0) - 1 : 1,
    };
  }

  void removeProduct(String productId) {
    state = Map.from(state)..remove(productId);
  }
}