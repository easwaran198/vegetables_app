import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:vegetables_app/models/frequent_product.dart';
import 'package:vegetables_app/models/offer_product.dart';
import 'package:vegetables_app/providers/home_data_notifier.dart';
import 'package:vegetables_app/screens/product_detail_screen.dart';
import 'package:vegetables_app/utils/contants_color.dart'; // Assuming this defines 'backgroundColor'
import 'package:vegetables_app/widgets/MyHeadingText.dart'; // Your custom heading text widget
import 'package:vegetables_app/widgets/MyTextContent.dart'; // Your custom text content widget
import 'package:vegetables_app/models/product.dart'; // Your Product model
import 'package:vegetables_app/widgets/quantity_selector.dart'; // Your API-integrated QuantitySelector


class ExploreScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase(); // Update search query, convert to lowercase for case-insensitive search
    });
  }

  @override
  Widget build(BuildContext context) {
    final productListAsyncValue = ref.watch(productListNotifierProvider("3"));
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: screenWidth*0.9,
                      height: 55,
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: backgroundColor, // Using the global constant
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0), // Adjust vertical padding for TextFormField
                      child: Row( // Changed to non-const Row
                        children: [
                          const Icon(Icons.search, color: Colors.white),
                          const SizedBox(width: 8), // Spacing between icon and text field
                          Expanded( // Use Expanded to allow TextFormField to fill available space
                            child: TextFormField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white, fontSize: 14), // Text input style
                              cursorColor: Colors.white, // Cursor color
                              decoration: const InputDecoration(
                                hintText: "Search",
                                hintStyle: TextStyle(color: Colors.white70, fontSize: 12), // Hint text style
                                border: InputBorder.none, // Remove default border
                                focusedBorder: InputBorder.none, // Remove focused border
                                enabledBorder: InputBorder.none, // Remove enabled border
                                errorBorder: InputBorder.none, // Remove error border
                                disabledBorder: InputBorder.none, // Remove disabled border
                                contentPadding: EdgeInsets.zero, // Remove default content padding
                                isDense: true, // Make it dense to reduce vertical space
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyHeadingText(text: "Explore Vegetables", fontSize: 19, backgroundColor: Colors.white, textColor: Colors.black),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // --- Conditional UI based on productListAsyncValue state ---
                productListAsyncValue.when(
                  loading: () => const Center(child: CupertinoActivityIndicator()), // Show loading spinner
                  error: (err, stack) => Center(child: Text('Error: ${err.toString()}')), // Show error message
                  data: (products) {
                    if (products.isEmpty) {
                      return const Center(child: Text('No products found.')); // Message if list is empty
                    }

                    // Filter products based on search query
                    final filteredProducts = products.where((product) {
                      return product.name.toLowerCase().contains(_searchQuery) ||
                          product.productBenefits.toLowerCase().contains(_searchQuery) ||
                          product.unit.toLowerCase().contains(_searchQuery); // Example: search by name, benefits, unit
                    }).toList();

                    if (filteredProducts.isEmpty && _searchQuery.isNotEmpty) {
                      return const Center(child: Text('No matching products found.'));
                    } else if (filteredProducts.isEmpty) {
                      return const Center(child: Text('No products available.')); // Should ideally not happen if 'products' is not empty
                    }

                    return GridView.builder(
                      itemCount: filteredProducts.length, // Use filtered list count
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(5),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.65,
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredProducts[index]; // Use filtered list item
                        return ScaleTransition(
                          scale: _scaleAnimation,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(product: item),
                                ),
                              );
                            },
                            child: VegetableCard(item),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------
// VegetableCard (Reusable widget - ideally in a separate file like lib/widgets/vegetable_card.dart)
// -----------------------------------------------------------
class VegetableCard extends StatelessWidget {
  final Product item;
  const VegetableCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ProductDetailPage(product: item);
              }));
            },
            child: Hero( // Hero for smooth transition to detail page
              tag: 'productHero-${item.id}', // Unique tag for Hero animation based on product ID
              child: Stack(
                children: [
                  Container(
                    width: 100, // Fixed width for the image container
                    height: 80, // Fixed height for the image container
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200, // Light grey background for image area
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item.images.isNotEmpty ? item.images[0] : 'assets/images/tomato.png', // Fallback to local asset if no URL
                        fit: BoxFit.fitHeight, // Adjust image fit to fill height
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/images/tomato.png', fit: BoxFit.fitHeight); // Fallback on network error
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.yellow, // This seems like an odd color for a cart icon background
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(Icons.add_shopping_cart, color: Colors.red, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            // Use Symmetric padding to ensure price and unit fit
            margin: const EdgeInsets.only(left: 8, right: 8, top: 8), // Reduced horizontal margin
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Allow price to take less space if needed
                Flexible(
                  child: MyHeadingText(text: "₹${item.price}", fontSize: 15, backgroundColor: Colors.white, textColor: Colors.black), // Slightly reduced font size
                ),
                Flexible(
                    child: Mytextcontent(text: "1 ${item.unit}", fontSize: 12, backgroundColor: Colors.white, textColor: Colors.black) // Slightly reduced font size
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0), // Added horizontal padding
            child: Text(
              item.name,
              style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold), // Reduced font size
              textAlign: TextAlign.center,
              maxLines: 2, // Allows text to wrap to 2 lines
              overflow: TextOverflow.ellipsis, // Adds "..." if text still overflows
            ),
          ),
          const SizedBox(height: 3),
          Expanded( // Using Expanded here to make sure QuantitySelector tries to fit horizontally
            child: FittedBox( // Use FittedBox to scale the QuantitySelector if it's still too wide
              fit: BoxFit.scaleDown, // Scales down, preferring to fit horizontally
              child: QuantitySelector(
                productId: item.id,
                initialQuantity: '1 ${item.unit}',
                unit: item.unit,
              ),
            ),
          ),
          const SizedBox(height: 3),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------
// OfferCard (Reusable widget - ideally in a separate file like lib/widgets/offer_card.dart)
// -----------------------------------------------------------
class OfferCard extends StatelessWidget {
  final OfferProduct item; // Now expects a Product object
  const OfferCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    // --- Dynamic Calculation of Original Price and Discount Percentage ---
    double currentPrice = double.tryParse(item.price) ?? 0.0;
    String discountPercentageStr = item.productBenefits ?? "0"; // Assuming a 'discount' field in Product
    double discountPercentage = double.tryParse(discountPercentageStr) ?? 0.0;

    double originalPrice = currentPrice;
    if (discountPercentage > 0 && discountPercentage < 100) {
      originalPrice = currentPrice / (1 - (discountPercentage / 100));
    }
    // --- End Dynamic Calculation ---

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7), // Soft offer background color
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Left: Text info1
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(item.name, // Dynamic product name
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text("₹${item.price.toString()}", // Dynamic current price
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        // Only show original price if it's different and meaningful
                        if (originalPrice > currentPrice && discountPercentage > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Text("₹${originalPrice.toStringAsFixed(0)}", // Dynamic original price
                                style: const TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey)),
                          ),
                        const SizedBox(width: 10),
                        const Text("Unit ", style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                        Text(": 1${item.unit}", style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold)), // Dynamic unit
                      ],
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(height: 8),
                    // Pass product details to QuantitySelector for API calls
                    QuantitySelector(
                      productId: item.id,
                      initialQuantity: '1 ${item.unit}',
                      unit: item.unit,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right: Vegetable Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.images.isNotEmpty ? item.images[0].imageUrl : 'assets/images/tomato.png', // Fallback to local asset
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/images/tomato.png', height: 80, width: 80, fit: BoxFit.cover); // Fallback on error
                  },
                ),
              ),
            ],
          ),
        ),

        // BEST OFFER Badge on top-left outside content
        Positioned(
          top: 0,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "BEST OFFER ${discountPercentage.toStringAsFixed(0)}%", // Display calculated discount
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}