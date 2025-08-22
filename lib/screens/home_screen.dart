import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegetables_app/models/product.dart';
import 'package:vegetables_app/models/category_res.dart';
import 'package:vegetables_app/providers/cart_provider.dart';
import 'package:vegetables_app/screens/cart_list_screen.dart';
import 'package:vegetables_app/screens/category_product_screen.dart';
import 'package:vegetables_app/screens/explore_screen.dart' hide VegetableCard;
import 'package:vegetables_app/screens/profile_screen.dart';
import 'package:vegetables_app/utils/contants_color.dart';
import 'package:vegetables_app/widgets/MyHeadingText.dart';
import 'package:vegetables_app/widgets/MyTextContent.dart';
import 'package:vegetables_app/widgets/custom_text_form_field.dart';
import 'package:vegetables_app/screens/product_detail_screen.dart';
import '../providers/home_data_notifier.dart';

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
  late int _selectedIndex;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
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
    searchController.removeListener(_onSearchChanged);
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
        onTap: _onTap,
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
      ExploreScreen(),
      ProfileScreen(),
      CartListScreen(
        key: ValueKey('cartTab_$_selectedIndex'),
        index: 3,
        selectedIndex: _selectedIndex,
      ),
    ];

    return Scaffold(
      bottomNavigationBar: _buildBottomBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
    );
  }

  Widget _buildHomeScreenContent(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    final productListAsyncValue = ref.watch(productListNotifierProvider(""));
    final offerProductListAsyncValue = ref.watch(offerProductNotifierProvider);
    final bannerListAsyncValue = ref.watch(bannerNotifierProvider);
    final categoryListAsyncValue = ref.watch(categoryNotifierProvider);
    final frequentOrderAsyncValue = ref.watch(frequentOrderNotifierProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header Section
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

            // Banner Carousel Section
            bannerListAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading banners: ${err.toString()}')),
              data: (banners) {
                if (banners.isEmpty) {
                  return const SizedBox.shrink();
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

            // Categories Section
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
              child: MyHeadingText(
                text: "Shop by Categories",
                fontSize: 19,
                backgroundColor: Colors.white,
                textColor: Colors.black,
              ),
            ),
            categoryListAsyncValue.when(
              loading: () => Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 20),
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) {
                print('Category error details: $err');
                print('Category error stack: $stack');
                return Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error loading categories',
                          style: TextStyle(color: Colors.red[600], fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(categoryNotifierProvider.notifier).fetchCategories();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Retry', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                );
              },
              data: (categories) {
                if (categories.isEmpty) {
                  return Container(
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: const Center(child: Text('No categories found.')),
                  );
                }
                return Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        child: CategoryCard(category),
                      );
                    },
                  ),
                );
              },
            ),

            // Frequent Orders Section
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
              child: MyHeadingText(
                text: "Frequently Ordered",
                fontSize: 19,
                backgroundColor: Colors.white,
                textColor: Colors.black,
              ),
            ),
          frequentOrderAsyncValue.when(
            loading: () => Container(
              height: 160,
              margin: const EdgeInsets.only(bottom: 20),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => Container(
              height: 160,
              margin: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading frequent orders',
                      style: TextStyle(color: Colors.red[600], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(frequentOrderNotifierProvider.notifier).fetchFrequentOrders();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Retry', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
            data: (frequentProducts) {
              if (frequentProducts.isEmpty) {
                return Container(
                  height: 160,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: const Center(child: Text('No frequent orders found.')),
                );
              }

              return Container(
                height: 160,
                margin: const EdgeInsets.only(bottom: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: frequentProducts.length,
                  itemBuilder: (context, index) {
                    final product = frequentProducts[index];
                    return Container(
                      width: 130,
                      margin: const EdgeInsets.only(right: 12),
                      child: FrequentProductCard(product),
                    );
                  },
                ),
              );
            },
          ),


          // Explore Vegetables Section
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
                      _onTap(1);
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

            // Explore Vegetables Grid
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
                        child: VegetableCard(item),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 6),

            // Best Offers Section
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
            offerProductListAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading offers: ${err.toString()}')),
              data: (offerProducts) {
                final filteredOfferProducts = offerProducts.where((product) {
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
                    child: OfferCard(item),
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

// Category Card Widget
class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle category tap - navigate to category products
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsScreen(categoryId: category.id.toString()),
          ),
        );

      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(category.images ?? ''),
                  fit: BoxFit.cover,
                  onError: (_, __) => const Icon(Icons.category),
                ),
              ),
              child: category.images == null || category.images!.isEmpty
                  ? const Icon(Icons.category, size: 30, color: Colors.green)
                  : null,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                category.name ?? 'Category',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Updated Frequent Product Card Widget
class FrequentProductCard extends StatelessWidget {
  final Product product;

  const FrequentProductCard(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to product detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product,),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.images.first ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name ?? 'Product',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${product.price} / ${product.unit}",
                      style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}