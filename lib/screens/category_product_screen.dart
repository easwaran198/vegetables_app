import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/models/product.dart';
import 'package:vegetables_app/providers/home_data_notifier.dart';
import 'package:vegetables_app/screens/my_orders_screen.dart';
import 'package:vegetables_app/screens/product_detail_screen.dart';
import 'package:vegetables_app/widgets/quantity_selector.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  final String categoryId;
  const CategoryProductsScreen({Key? key, required this.categoryId})
    : super(key: key);


  @override
  ConsumerState<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends ConsumerState<CategoryProductsScreen> {
  late String currentCategoryId;

  @override
  void initState() {
    super.initState();
    print(widget.categoryId);
    currentCategoryId = widget.categoryId;
  }

  void updateCategory(String newCategoryId) {
    if (newCategoryId != currentCategoryId) {
      currentCategoryId = newCategoryId;
      ref.read(productListNotifierProvider(currentCategoryId).notifier).fetchProducts();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final productListAsyncValue = ref.watch(productListNotifierProvider(currentCategoryId));

    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: productListAsyncValue.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (products) {
          // Your grid view similar to ExploreScreen here
          return
            GridView.builder(
              itemCount: products.length > 6 ? 6 : products.length,
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
                final item = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(product: item),
                      ),
                    );
                  },
                  child: VegetableCard(item),
                );
              },
            );
        },
      ),
    );
  }
}
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
                    height: 70, // Fixed height for the image container
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
class OfferCard2 extends StatelessWidget {
  final Product item;
  const OfferCard2(this.item, {super.key});

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
                    height: 70, // Fixed height for the image container
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200, // Light grey background for image area
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item.images.isNotEmpty ? item.images[0] as String : 'assets/images/tomato.png',
                        fit: BoxFit.fitHeight,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/images/tomato.png', fit: BoxFit.fitHeight);
                        },
                      )
                      ,
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
