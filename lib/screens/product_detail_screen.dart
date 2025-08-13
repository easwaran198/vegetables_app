import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/models/product.dart';
import 'package:vegetables_app/providers/cart_provider.dart';
import 'package:vegetables_app/screens/home_screen.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  late int quantity;
  late int maxQuantity;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  late List<String> imageUrls;
  int selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize quantity from product data, default to 1
    quantity = 1;

    // Parse max quantity from string (e.g., "5kg" to 5)
    String maxString = widget.product.max.replaceAll('kg', '').trim();
    maxQuantity = int.tryParse(maxString) ?? 5; // Default to 5 if parsing fails

    // Use product images from the passed product object
    imageUrls = widget.product.images;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Function to add/update item in cart via API
  Future<void> _updateCartQuantity(int newQuantity) async {
    final cartService = ref.read(cartServiceProvider); // Access the cart service
    final productId = widget.product.id; // Assuming product.id is available

    try {
      // Call the API to update the quantity
      await cartService.addToCart(productId, newQuantity);

      // Update local state only if API call is successful
      setState(() {
        quantity = newQuantity;
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Updated ${widget.product.name} quantity to $newQuantity'),
            backgroundColor: Colors.green,duration: const Duration(seconds: 1) // Added const
        ),
      );

      // Invalidate cart list provider to refetch cart data on CartListScreen
      ref.invalidate(cartListProvider);

    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the passed product data using widget.product
    final Product product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Icon(Icons.share, size: 28),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: imageUrls.isNotEmpty
                  ? Image.network(
                imageUrls[selectedImageIndex],
                key: ValueKey<String>(imageUrls[selectedImageIndex] + selectedImageIndex.toString()),
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/tomato.png', // Fallback for network image errors
                    key: ValueKey<String>('assets/images/tomato' + selectedImageIndex.toString()),
                    height: 200,
                    fit: BoxFit.contain,
                  );
                },
              )
                  : Image.asset(
                'assets/images/tomato.png', // Fallback if imageUrls is empty
                key: ValueKey<String>('assets/images/tomato'),
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImageIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedImageIndex == index ? Colors.red : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          imageUrls[index],
                          height: 50,
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/images/tomato.png', height: 50, width: 60, fit: BoxFit.cover);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50.withOpacity(0.4),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Cart Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.name, // Dynamic product name
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.shopping_cart, color: Colors.green),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          ...List.generate(
                            5,
                                (index) => Icon(
                              index < double.parse(product.rating).floor()
                                  ? Icons.star
                                  : Icons.star_border, // Show half star if needed
                              color: Colors.orange,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(product.rating),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Price + Quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "₹${product.price} ", // Dynamic price
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: "/ 1${product.unit}", // Dynamic unit
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                const TextSpan(
                                  text: "  ",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: "max ${product.max}", // Dynamic max quantity
                                  style: const TextStyle(
                                    color: Colors.deepPurpleAccent,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () {
                                  if (quantity > 1) {
                                    _updateCartQuantity(quantity - 1); // Call API on decrement
                                  }
                                },
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                        scale: animation, child: child),
                                child: Text(
                                  '$quantity ${product.unit}', // Display selected quantity with unit
                                  key: ValueKey<int>(quantity),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.red),
                                onPressed: () {
                                  // Removed if (quantity < maxQuantity) to allow _updateCartQuantity to handle max
                                  _updateCartQuantity(quantity + 1); // Call API on increment
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text("Delivery by Apr 3, Thur", // This might also be dynamic
                          style: TextStyle(color: Colors.black87)),
                      const SizedBox(height: 5),

                      const Text("Product Benefits",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                      const SizedBox(height: 5),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          border: Border.all(
                              color: Colors.black26,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.productBenefits, // Dynamic product benefits
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),

                      const Spacer(),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await _updateCartQuantity(quantity);
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> VegetableShopScreen(initialIndex: 3,)));
                              },
                              icon: const Icon(Icons.add_shopping_cart,
                                  color: Colors.red),
                              label: const Text("Add to Cart",
                                  style: TextStyle(color: Colors.black)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                // Buy now logic here (usually adds to cart and then proceeds to checkout)
                                await _updateCartQuantity(quantity); // Ensure current quantity is added
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> VegetableShopScreen(initialIndex: 3,)));
                              },
                              child: Text("Buy ₹${double.parse(product.price) * quantity}", // Dynamic total price
                                  style: const TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}