import 'dart:convert';

// Represents a single item within an order
class OrderItem {
  final String id;
  final String name;
  final String price; // Price per unit/item
  final String rating;
  final String totalPrice; // Total price for this specific item (quantity * price)
  final String tamilName;
  final String productBenefits;
  final String image;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.totalPrice,
    required this.tamilName,
    required this.productBenefits,
    required this.image,
  });

  // Factory constructor to create an OrderItem from a JSON map
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as String,
      rating: json['rating'] as String,
      totalPrice: json['total_price'] as String,
      tamilName: json['tamil_name'] as String,
      productBenefits: json['product_benefits'] as String,
      image: json['image'] as String,
    );
  }
}

// Represents a complete order
class Order {
  final String orderId;
  final String paymentMode;
  final String totalAmount; // Total amount for the entire order
  final String orderStatus;
  final List<OrderItem> items; // List of items in this order

  Order({
    required this.orderId,
    required this.paymentMode,
    required this.totalAmount,
    required this.orderStatus,
    required this.items,
  });

  // Factory constructor to create an Order from a JSON map
  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse the list of items
    var itemsList = json['items'] as List;
    List<OrderItem> items = itemsList.map((i) => OrderItem.fromJson(i as Map<String, dynamic>)).toList();

    return Order(
      orderId: json['order_id'] as String,
      paymentMode: json['payment_mode'] as String,
      totalAmount: json['total_amount'] as String,
      orderStatus: json['order_status'] as String,
      items: items,
    );
  }
}

// Represents the overall API response structure
class MyOrdersResponse {
  final String success;
  final String error;
  final String message;
  final List<Order> orders; // List of orders received

  MyOrdersResponse({
    required this.success,
    required this.error,
    required this.message,
    required this.orders,
  });

  // Factory constructor to create MyOrdersResponse from a JSON map
  factory MyOrdersResponse.fromJson(Map<String, dynamic> json) {
    // Parse the list of orders
    var ordersList = json['orders'] as List;
    List<Order> orders = ordersList.map((o) => Order.fromJson(o as Map<String, dynamic>)).toList();

    return MyOrdersResponse(
      success: json['success'] as String,
      error: json['error'] as String,
      message: json['message'] as String,
      orders: orders,
    );
  }
}
