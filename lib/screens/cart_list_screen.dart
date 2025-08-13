import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:vegetables_app/screens/payment_screen.dart';
import 'package:vegetables_app/utils/contants_color.dart';
import 'package:vegetables_app/widgets/CartIconWithBadge.dart';
import 'package:vegetables_app/widgets/MyHeadingText.dart';
import 'package:vegetables_app/widgets/MyTextContent.dart';
import 'package:vegetables_app/providers/cart_provider.dart';
import 'package:vegetables_app/models/cart.dart';

class CartListScreen extends ConsumerStatefulWidget {
  final int index;
  final int selectedIndex;

  const CartListScreen({
    Key? key,
    required this.index,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  _CartListScreenState createState() => _CartListScreenState();
}

class _CartListScreenState extends ConsumerState<CartListScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _showSnackBar(String message, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(covariant CartListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == widget.index && oldWidget.selectedIndex != widget.index) {
      ref.invalidate(cartListProvider); // Invalidate the cartListProvider to force a refresh
      _searchController.clear(); // Clear search on tab switch
      _searchQuery = ""; // Reset search query
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var screenWidth = MediaQuery.of(context).size.width;

    final cartListAsyncValue = ref.watch(cartListProvider);
    final cartItemQuantities = ref.watch(cartItemQuantitiesProvider);
    final cartService = ref.read(cartServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyHeadingText(
                      text: "My Cart",
                      fontSize: 22,
                      backgroundColor: Colors.white,
                      textColor: Colors.black),
                  cartListAsyncValue.when(
                    data: (cartResponse) {
                      final totalQty = cartResponse.cart.length;
                      return CartIconWithBadge(
                        itemCount: totalQty,
                        onPressed: () {
                          // Already on cart page, maybe refresh or do nothing
                        },
                      );
                    },
                    loading: () => CartIconWithBadge(itemCount: 0, onPressed: () {}),
                    error: (err, stack) => CartIconWithBadge(itemCount: 0, onPressed: () {}),
                  ),
                ],
              ),
            ),
            Container(
              width: screenWidth * 0.9, // Adjust width as needed
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: backgroundColor,
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white),
                  hintText: "Search your cart items...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            cartListAsyncValue.when(
              data: (cartResponse) {
                final filteredCart = cartResponse.cart.where((item) {
                  return item.productName.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredCart.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Mytextcontent(
                        text: _searchQuery.isEmpty ? "Your cart is empty!" : "No items found for '${_searchQuery}'",
                        fontSize: 18,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                      ),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref
                      .read(cartItemQuantitiesProvider.notifier)
                      .setInitialQuantities(cartResponse.cart); // Use original cart to set quantities
                });

                return Expanded(
                  child: ListView.builder(
                    itemCount: filteredCart.length,
                    itemBuilder: (context, index) {
                      final item = filteredCart[index];
                      final currentQuantity =
                          cartItemQuantities[item.productId] ??
                              int.tryParse(item.qty) ??
                              0;

                      return CartItemCard(
                        item: item,
                        currentQuantity: currentQuantity,
                        onIncrement: () async {
                          final newQuantity = currentQuantity + 1;
                          try {
                            await cartService.addToCart(item.productId, newQuantity);
                            ref.read(cartItemQuantitiesProvider.notifier).incrementQuantity(item.productId);
                            ref.invalidate(cartListProvider);
                            _showSnackBar("Quantity updated successfully!");
                          } catch (e) {
                            _showSnackBar("Failed to update quantity: ${e.toString()}", color: Colors.red);
                            print("Error incrementing: $e");
                          }
                        },
                        onDecrement: () async {
                          if (currentQuantity > 1) {
                            final newQuantity = currentQuantity - 1;
                            try {
                              await cartService.addToCart(item.productId, newQuantity);
                              ref.read(cartItemQuantitiesProvider.notifier).decrementQuantity(item.productId);
                              ref.invalidate(cartListProvider);
                              _showSnackBar("Quantity updated successfully!");
                            } catch (e) {
                              _showSnackBar("Failed to update quantity: ${e.toString()}", color: Colors.red);
                              print("Error decrementing: $e");
                            }
                          } else {
                            _showSnackBar("Quantity cannot be less than 1.", color: backgroundColor);
                          }
                        },
                        onRemove: () async {
                          try {
                            await cartService.deleteCartItem(item.productId);
                            ref.read(cartItemQuantitiesProvider.notifier).removeProduct(item.productId);
                            ref.invalidate(cartListProvider);
                            _showSnackBar("Item removed from cart successfully!");
                          } catch (e) {
                            _showSnackBar("Failed to remove item: ${e.toString()}", color: Colors.red);
                            print("Error removing item: $e");
                          }
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              ),
              error: (error, stack) => Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Mytextcontent(
                        text: "Failed to load cart. Please retry.",
                        fontSize: 16,
                        backgroundColor: Colors.white,
                        textColor: Colors.red,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(cartListProvider);
                        },
                        child: Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: backgroundColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            cartListAsyncValue.when(
              data: (cartResponse) {
                if (cartResponse.cart.isEmpty) {
                  return SizedBox.shrink();
                }
                return Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyHeadingText(
                              text: "Total Amount:",
                              fontSize: 18,
                              backgroundColor: Colors.white,
                              textColor: Colors.black),
                          MyHeadingText(
                              text: "₹${cartResponse.totalAmount}",
                              fontSize: 20,
                              backgroundColor: Colors.white,
                              textColor: Colors.orange),
                        ],
                      ),
                      SizedBox(height: 15),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PaymentScreen(orderTotalAmount: cartResponse.totalAmount)));
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Mytextcontent(
                                text: "Proceed to Checkout",
                                fontSize: 18,
                                backgroundColor: backgroundColor,
                                textColor: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => SizedBox.shrink(),
              error: (err, stack) => SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// Your CartItemCard, VegetableCard, OfferCard definitions follow, they are fine
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final int currentQuantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.currentQuantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final double rating = 4.0;

    return Container(
      margin: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
      padding: EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.black)),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.3,
            child: Column(
              children: [
                Container(
                  height: screenHeight * 0.12,
                  child: item.image.isNotEmpty
                      ? Image.network(
                    item.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset("assets/images/tomato.png"),
                  )
                      : Image.asset("assets/images/tomato.png"),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(color: Colors.white70),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: onDecrement,
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(6)),
                            child: const Icon(Icons.remove, color: Colors.white)),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${currentQuantity} ${item.unit}', // Display current quantity and unit
                          style:
                          const TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                      GestureDetector(
                        onTap: onIncrement,
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6)),
                            child: const Icon(Icons.add, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Mytextcontent(
                    text: item.productName,
                    fontSize: 18,
                    backgroundColor: Colors.white,
                    textColor: Colors.black),
                Row(
                  children: [
                    Mytextcontent(
                        text: "₹${item.price}",
                        fontSize: 18,
                        backgroundColor: Colors.white,
                        textColor: Colors.green),
                    SizedBox(width: 10),
                    Mytextcontent(
                        text: "${item.unit}",
                        fontSize: 15,
                        backgroundColor: Colors.white,
                        textColor: Colors.black),
                    SizedBox(width: 10),
                  ],
                ),
                Mytextcontent(
                    text: "(Total: ₹${double.parse(item.price) * currentQuantity})", // Calculate total amount based on local quantity
                    fontSize: 15,
                    backgroundColor: Colors.white,
                    textColor: Colors.blue),
                RatingBarIndicator(
                  rating: rating,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 30.0,
                  direction: Axis.horizontal,
                ),
                SizedBox(height: 10),
                Center(
                  child: InkWell(
                    onTap: onRemove,
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          border: Border.all(color: Colors.black)),
                      child: Row(
                        children: [
                          Container(
                              height: 20,
                              alignment: AlignmentDirectional.topCenter,
                              child: Icon(Icons.delete)),
                          Mytextcontent(
                              text: "Remove",
                              fontSize: 12,
                              backgroundColor: backgroundColor,
                              textColor: Colors.red)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}