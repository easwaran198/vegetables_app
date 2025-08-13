import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegetables_app/providers/banner_notifier.dart';
import 'package:vegetables_app/providers/cart_provider.dart';
import 'package:vegetables_app/screens/cart_list_screen.dart';
import 'package:vegetables_app/screens/explore_screen.dart';
import 'package:vegetables_app/screens/profile_screen.dart'; // Ensure this import is correct
import 'package:vegetables_app/utils/contants_color.dart';
import 'package:vegetables_app/widgets/MyHeadingText.dart';
import 'package:vegetables_app/widgets/MyTextContent.dart';
import 'package:vegetables_app/widgets/custom_text_form_field.dart';
import 'package:vegetables_app/providers/product_list_notifier.dart';
import 'package:vegetables_app/providers/offer_product_notifier.dart';
import 'package:vegetables_app/screens/product_detail_screen.dart';

class VegetableShopScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const VegetableShopScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<VegetableShopScreen> createState() => _VegetableShopScreenState();
}

class _VegetableShopScreenState extends ConsumerState<VegetableShopScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final TextEditingController searchController = TextEditingController();
  String token = "";
  late int _selectedIndex; // Make it late and initialize in initState
  String _searchQuery = ''; // NEW: State variable for the search query

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Initialize with the value from the widget
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    checkLoginStatus();

    searchController.addListener(_onSearchChanged);
  }


  void _onSearchChanged() {
    setState(() {
      _searchQuery = searchController.text;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    searchController.removeListener(_onSearchChanged); // NEW: Remove listener
    searchController.dispose();
    super.dispose();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    if (storedToken != null) {
      setState(() {
        token = storedToken;
      });
      print('Retrieved token: $token');
    } else {
      print('No token found.');
    }
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // If the cart tab is tapped (index 3), invalidate the cart provider
    if (index == 3) {
      ref.invalidate(cartListProvider);
      print('VegetableShopScreen: Cart tab tapped, invalidating cartListProvider directly.');
    }
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, Color(0Xff911354)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap, // This handles tab changes
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeScreenContent(context),
      ExploreScreen(), // ExploreScreen is at index 1
      // Pass the _onTap callback to ProfileScreen for navigation to cart
      ProfileScreen(), // Pass callback here to navigate to Cart (index 3)
      CartListScreen(
        key: ValueKey('cartTab_$_selectedIndex'), // Key helps Flutter re-render if needed
        index: 3,
        selectedIndex: _selectedIndex,
      ),
    ];

    return Scaffold(
      bottomNavigationBar: _buildBottomBar(),
      body: IndexedStack(
        index: _selectedIndex, // Displays the screen corresponding to the selected tab
        children: screens,
      ),
    );
  }

  Widget _buildHomeScreenContent(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    final productListAsyncValue = ref.watch(productListNotifierProvider);
    final offerProductListAsyncValue = ref.watch(offerProductNotifierProvider);
    final bannerListAsyncValue = ref.watch(bannerNotifierProvider); // Watch the new provider


    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: screenHeight * 0.28,
              margin: const EdgeInsets.only(left: 10, right: 10),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/header_home.png"),
                  fit: BoxFit.fitHeight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        child: Image.asset("assets/images/logo.png"),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hey Rinkuhh !",
                            style: GoogleFonts.rammettoOne(
                                color: Colors.yellow, fontSize: 22),
                          ),
                          Mytextcontent(
                            text: "Explore our fresh Vegetables",
                            fontSize: 12,
                            textColor: Colors.white,
                            backgroundColor: backgroundColor,
                          )
                        ],
                      ),
                      const CircleAvatar(
                        child: Icon(
                          Icons.notification_important,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.only(left: 35.0, right: 35.0),
                    child: CustomTextFormField(
                      controller: searchController,
                      hintText: "Search",
                      backgroundColor: Colors.white,
                      borderlineColor: Colors.white,
                      prefixIcon: Icons.search,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            bannerListAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading banners: ${err.toString()}')),
              data: (banners) {
                if (banners.isEmpty) {
                  return const SizedBox.shrink(); // Hide if no banners
                }
                return CarouselSlider(
                  options: CarouselOptions(
                    height: 150.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                  ),
                  items: banners.map((banner) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(banner.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyHeadingText(
                    text: "Explore Vegetables",
                    fontSize: 19,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                  ),
                  InkWell(
                    onTap: () {
                      // Navigate to ExploreScreen by setting the _selectedIndex
                      _onTap(1); // 1 is the index for ExploreScreen in your BottomNavigationBar
                    },
                    child: Mytextcontent(
                      text: "View all",
                      fontSize: 12,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 6),

            // --- Explore Vegetables Grid (New Products) ---
            productListAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                return GridView.builder(
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
                        // Ensure VegetableCard expects a Product item
                        child: VegetableCard(item),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 6),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(12.0),
              child: MyHeadingText(
                text: "Best Offer",
                fontSize: 20,
                backgroundColor: Colors.white,
                textColor: Colors.black,
              ),
            ),
            // --- Best Offers List ---
            offerProductListAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading offers: ${err.toString()}')),
              data: (offerProducts) {
                // NEW: Filter offerProducts based on _searchQuery
                final filteredOfferProducts = offerProducts.where((product) {
                  // Ensure Product has a 'name' property for filtering
                  final productNameLower = product.name.toLowerCase();
                  final searchQueryLower = _searchQuery.toLowerCase();
                  return productNameLower.contains(searchQueryLower);
                }).toList();

                if (filteredOfferProducts.isEmpty && _searchQuery.isNotEmpty) {
                  return const Center(child: Text('No offers available matching your search.'));
                } else if (filteredOfferProducts.isEmpty) {
                  return const Center(child: Text('No offers available.'));
                }

                return Column(
                  children: filteredOfferProducts.map((item) => ScaleTransition(
                    scale: _scaleAnimation,
                    // Ensure OfferCard expects a Product item
                    child: OfferCard(item), // Assuming OfferCard takes a Product object
                  )).toList(),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}