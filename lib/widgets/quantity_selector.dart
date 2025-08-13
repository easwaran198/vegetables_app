import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegetables_app/utils/contants_color.dart';
import 'package:vegetables_app/providers/dio_provider.dart';

class QuantitySelector extends ConsumerStatefulWidget {
  final String productId;
  final String initialQuantity;
  final String unit;
  final ValueChanged<int>? onQuantityChanged;

  const QuantitySelector({
    Key? key,
    required this.productId,
    required this.initialQuantity,
    required this.unit,
    this.onQuantityChanged,
  }) : super(key: key);

  @override
  ConsumerState<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends ConsumerState<QuantitySelector> {
  late int quantity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    String qtyString = widget.initialQuantity.replaceAll(widget.unit, '').trim();
    quantity = int.tryParse(qtyString) ?? 1;
  }

  Future<void> _updateCartQuantity(int newQuantity) async {
    setState(() {
      _isLoading = true;
    });

    final dio = ref.read(dioProvider);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Get the token

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found. Please log in.'),duration: Duration(seconds: 1),),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await dio.post(
        'http://ttbilling.in/vegetable_app/api/add_to_cart',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'token': token,
          },
        ),
        data: {
          'product_id': widget.productId,
          'quantity': newQuantity,
        },
      );

      print(widget.productId);
      print(newQuantity.toString());
      print(token);
      print(response);
      if (response.statusCode == 200 && response.data['success'] == 'true') {
        setState(() {
          quantity = newQuantity;
        });
        if (widget.onQuantityChanged != null) {
          widget.onQuantityChanged!(newQuantity);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['messgae'] ?? 'Cart updated successfully!'),duration: Duration(seconds: 1),),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['messgae'] ?? 'Failed to update cart.'),duration: Duration(seconds: 1),),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update cart. Please try again.';
      if (e.response != null) {
        print('Dio error: ${e.response?.statusCode} - ${e.response?.data}');
        if (e.response?.statusCode == 401) {
          errorMessage = 'Session expired. Please log in again.';
        } else if (e.response?.data != null && e.response?.data['messgae'] != null) {
          errorMessage = e.response?.data['messgae'];
        }
      } else {
        print('Network error: ${e.message}');
        errorMessage = 'Network error: Please check your internet connection.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage),duration: Duration(seconds: 1),),
      );
    } catch (e) {
      print('Unexpected error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.'),duration: Duration(seconds: 1),),
      );
    } finally {
      setState(() {
        _isLoading = false; // Always set loading to false
      });
    }
  }

  void increment() {
    // Implement your max quantity logic here if needed,
    // e.g., if (quantity < widget.maxProductQuantity) { ... }
    _updateCartQuantity(quantity + 1);
  }

  void decrement() {
    if (quantity > 1) { // Prevent quantity from going below 1
      _updateCartQuantity(quantity - 1);
    } else {
      // Optional: Inform user that quantity cannot be less than 1, or remove item from cart.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity cannot be less than 1. Remove item from cart if not needed.'),duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor, // Assuming backgroundColor is defined
      child: Row(
        mainAxisSize: MainAxisSize.min, // keep the row compact
        children: [
          GestureDetector(
            onTap: _isLoading ? null : decrement, // Disable while loading
            child: Container(
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
                child: _isLoading && quantity == 1 ? const CupertinoActivityIndicator(color: Colors.white) : const Icon(Icons.remove, color: Colors.white)),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isLoading && quantity > 1 // Show loading indicator only on change and not for initial 1
                ? const CupertinoActivityIndicator(color: Colors.white)
                : Text(
              '$quantity ${widget.unit}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: _isLoading ? null : increment, // Disable while loading
            child: Container(
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                child: _isLoading ? const CupertinoActivityIndicator(color: Colors.white) : const Icon(Icons.add, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}