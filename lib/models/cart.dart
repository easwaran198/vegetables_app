// lib/models/cart.dart

class CartResponse {
  final bool success;
  final bool error;
  final String message;
  final String totalQty;
  final String totalAmount;
  final List<CartItem> cart;

  CartResponse({
    required this.success,
    required this.error,
    required this.message,
    required this.totalQty,
    required this.totalAmount,
    required this.cart,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      success: json['success'] == 'true',
      error: json['error'] == 'true',
      message: json['message'] as String,
      totalQty: json['total_qty'] as String,
      totalAmount: json['total_amount'] as String,
      cart: (json['cart'] as List)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String unit;
  final String price;
  final String qty;
  final String amount;
  final String image;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unit,
    required this.price,
    required this.qty,
    required this.amount,
    required this.image,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      unit: json['unit'] as String,
      price: json['price'] as String,
      qty: json['qty'] as String,
      amount: json['amount'] as String,
      image: json['image'] as String,
    );
  }
}