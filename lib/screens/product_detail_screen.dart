import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/models/product.dart';
import 'package:vegetables_app/providers/cart_provider.dart';
import 'package:vegetables_app/providers/home_data_notifier.dart'; // Add this import
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

  /// local mutable wishlist state
  late int wishcount;

  @override
  void initState() {
    super.initState();

    quantity = 1;
    String maxString = widget.product.max.replaceAll('kg', '').trim();
    maxQuantity = int.tryParse(maxString) ?? 5;

    imageUrls = widget.product.images;

    wishcount = widget.product.wishcount; // copy initial wishlist value

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    print(wishcount);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateCartQuantity(int newQuantity) async {
    final cartService = ref.read(cartServiceProvider);
    final productId = widget.product.id;

    try {
      await cartService.addToCart(productId, newQuantity);
      setState(() {
        quantity = newQuantity;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated ${widget.product.name} quantity to $newQuantity'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );

      ref.invalidate(cartListProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleWishlist() async {
    final cartService = ref.read(cartServiceProvider);
    final productId = widget.product.id;

    var newStatus = 0;
    if(wishcount == 0){
      newStatus = 1;
    }else{

    }

    print(wishcount);
    print(newStatus);

    try {
      await cartService.addToWishlist(productId, newStatus);



      // CRITICAL: Invalidate the wishlist provider to refresh the data
      ref.invalidate(wishListNotifierProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 1
                ? 'Added ${widget.product.name} to wishlist'
                : 'Removed ${widget.product.name} from wishlist',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );

      setState(() {
        wishcount = newStatus;
      });
      // Navigate back to wishlist screen (index 1)
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => VegetableShopScreen(initialIndex: 1)
          )
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update wishlist: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // top bar
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

            // main image
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: imageUrls.isNotEmpty
                  ? Image.network(
                imageUrls[selectedImageIndex],
                key: ValueKey(
                    imageUrls[selectedImageIndex] + selectedImageIndex.toString()),
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/tomato.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              )
                  : Image.asset(
                'assets/images/tomato.png',
                key: const ValueKey('assets/images/tomato'),
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 5),

            // thumbnails
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedImageIndex = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedImageIndex == index
                              ? Colors.red
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          imageUrls[index],
                          height: 50,
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/tomato.png',
                            height: 50,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // slide-up section
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50.withOpacity(0.4),
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.shopping_cart, color: Colors.green),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // rating
                      Row(
                        children: [
                          ...List.generate(
                            5,
                                (index) => Icon(
                              index < double.parse(product.rating).floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.orange,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(product.rating),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // price + quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "₹${product.price} ",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: "/ 1${product.unit}",
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                const TextSpan(text: "  "),
                                TextSpan(
                                  text: "max ${product.max}",
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
                                    _updateCartQuantity(quantity - 1);
                                  }
                                },
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                        scale: animation, child: child),
                                child: Text(
                                  '$quantity ${product.unit}',
                                  key: ValueKey<int>(quantity),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle,
                                    color: Colors.red),
                                onPressed: () =>
                                    _updateCartQuantity(quantity + 1),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text("Delivery by Apr 3, Thur",
                          style: TextStyle(color: Colors.black87)),
                      const SizedBox(height: 5),

                      const Text("Product Benefits",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green)),
                      const SizedBox(height: 5),

                      Container(
                        width: double.infinity,
                        height: 100,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.productBenefits,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                        ),
                      ),

                      const Spacer(),

                      // wishlist + buy buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _toggleWishlist,
                              icon: Icon(
                                wishcount == 1
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              label: Text(
                                wishcount == 1
                                    ? "Remove from Wishlist"
                                    : "Add to Wishlist",
                                style:
                                const TextStyle(color: Colors.black),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await _updateCartQuantity(quantity);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VegetableShopScreen(initialIndex: 3),
                                  ),
                                );
                              },
                              child: Text(
                                "Buy ₹${double.parse(product.price) * quantity}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
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