import 'package:vegetables_app/models/product.dart';

class FrequentOrderResponse {
  final String? success;
  final String? error;
  final List<Product>? products;

  FrequentOrderResponse({
    this.success,
    this.error,
    this.products,
  });

  factory FrequentOrderResponse.fromJson(Map<String, dynamic> json) {
    return FrequentOrderResponse(
      success: json['success'] as String?,
      error: json['error'] as String?,
      products: (json['products'] as List<dynamic>?)
          ?.map((p) => p != null ? Product.fromJson(p) : null) // handle null
          .whereType<Product>() // remove nulls
          .toList(),
    );
  }
}
