import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../product/product_detail.dart';
import '../auth/login_screen.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final wishlistCollection = FirebaseFirestore.instance.collection('wishlists');
  final cartCollection = FirebaseFirestore.instance.collection('carts');

  User? user;
  List<Map<String, dynamic>> cartItems = [];
  String searchQuery = "";

  final PageController _bannerController = PageController();
  int _currentBanner = 0;

  final List<Map<String, dynamic>> categories = [
    {"name": "Diapers", "icon": Icons.child_care, "items": 45},
    {"name": "Feeding", "icon": Icons.restaurant, "items": 32},
    {"name": "Toys", "icon": Icons.toys, "items": 67},
    {"name": "Clothing", "icon": Icons.checkroom, "items": 89},
    {"name": "Bath", "icon": Icons.bathtub, "items": 23},
    {"name": "Health", "icon": Icons.medical_services, "items": 15},
  ];

  final List<Map<String, dynamic>> testimonials = [
    {
      "name": "Sarah Johnson",
      "comment": "Amazing quality products! My baby loves the toys and the diapers are super comfortable.",
      "rating": 5,
      "image": "assets/images/user1.png"
    },
    {
      "name": "Mike Chen",
      "comment": "Fast delivery and excellent customer service. Will definitely shop again!",
      "rating": 4,
      "image": "assets/images/user2.png"
    },
    {
      "name": "Priya Sharma",
      "comment": "The baby clothes are so soft and perfect for my newborn. Highly recommended!",
      "rating": 5,
      "image": "assets/images/user3.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _fetchCart();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_bannerController.hasClients) {
        if (_currentBanner < 2) {
          _bannerController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _bannerController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _fetchCart() async {
    if (user == null) return;
    final doc = await cartCollection.doc(user!.uid).get();
    if (doc.exists) {
      final data = doc.data();
      setState(() {
        cartItems = List<Map<String, dynamic>>.from(data?['items'] ?? []);
      });
    }
  }

  bool _isInCart(String productName) {
    return cartItems.any((item) => item['name'] == productName);
  }

  Future<void> _toggleCart(Map<String, dynamic> product) async {
    if (user == null) return;
    final docRef = cartCollection.doc(user!.uid);
    final productName = product['name'];

    if (_isInCart(productName)) {
      cartItems.removeWhere((item) => item['name'] == productName);
      await docRef.set({'items': cartItems});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pinkAccent,
          content: Text("Removed from cart 🗑️", style: TextStyle(color: Colors.white)),
        ),
      );
    } else {
      cartItems.add({
        'name': product['name'],
        'price': product['price'],
        'imageUrl': product['imageUrl'],
        'qty': 1,
      });
      await docRef.set({'items': cartItems});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pinkAccent,
          content: Text("Added to cart 🛒", style: TextStyle(color: Colors.white)),
        ),
      );
    }
    setState(() {});
  }

  Future<void> _toggleWishlist(Map<String, dynamic> product, List<Map<String, dynamic>> wishlistItems) async {
    if (user == null) return;
    final docRef = wishlistCollection.doc(user!.uid);
    final productName = product['name'];

    if (wishlistItems.any((item) => item['name'] == productName)) {
      wishlistItems.removeWhere((item) => item['name'] == productName);
      await docRef.set({'items': wishlistItems});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pinkAccent,
          content: Text("Removed from wishlist", style: TextStyle(color: Colors.white)),
        ),
      );
    } else {
      wishlistItems.add(product);
      await docRef.set({'items': wishlistItems});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pinkAccent,
          content: Text("Added to wishlist", style: TextStyle(color: Colors.white)),
        ),
      );
    }
    setState(() {});
  }

  Stream<List<Map<String, dynamic>>> getWishlistStream() {
    if (user == null) return const Stream.empty();
    return wishlistCollection.doc(user!.uid).snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data();
      return List<Map<String, dynamic>>.from(data?['items'] ?? []);
    });
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildBannerSection() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBanner = index;
              });
            },
            children: [
              _buildBannerCard("Summer Sale", "Get 30% off on all baby clothes", Colors.pinkAccent),
              _buildBannerCard("New Arrivals", "Check out our latest products", Colors.blueAccent),
              _buildBannerCard("Free Delivery", "On orders above Rs. 2000", Colors.greenAccent),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentBanner == index ? Colors.pinkAccent : Colors.grey.shade300,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerCard(String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.8), color],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Shop Now",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Categories",
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CategoryScreen(category: {"name": "All Categories"})),
                  );
                },
                child: const Text(
                  "See All",
                  style: TextStyle(color: Colors.pinkAccent),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                width: 80,
                margin: EdgeInsets.only(right: index == categories.length - 1 ? 0 : 12),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category["icon"],
                        color: Colors.pinkAccent,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category["name"],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comfortaa(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            "What Parents Say",
            style: GoogleFonts.comfortaa(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              final testimonial = testimonials[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(right: index == testimonials.length - 1 ? 0 : 16),
                child: Card(
                  elevation: 2,
                  color: Colors.pink.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.pinkAccent.withOpacity(0.1),
                              child: const Icon(
                                Icons.person,
                                color: Colors.pinkAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    testimonial["name"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  _buildRatingStars(testimonial["rating"].toDouble()),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          testimonial["comment"],
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getWishlistStream(),
      builder: (context, wishlistSnapshot) {
        final wishlistItemsLive = wishlistSnapshot.data ?? [];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent),
              );
            }

            final allProducts = snapshot.data?.docs ?? [];
            if (allProducts.isEmpty) {
              return const Center(
                child: Text("No products found", style: TextStyle(color: Colors.black54)),
              );
            }

            List<Map<String, dynamic>> productList =
                allProducts.map((e) => e.data() as Map<String, dynamic>).toList();

            // Search filter
            productList = productList.where((data) =>
                (data['name']?.toString().toLowerCase() ?? '')
                    .contains(searchQuery)).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "Featured Products",
                    style: GoogleFonts.comfortaa(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productList.length > 4 ? 4 : productList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final product = productList[index];
                    final imageUrl = product['imageUrl'] ?? '';
                    final name = product['name'] ?? 'Unnamed';
                    final price = product['price'] ?? '0';
                    final isInWishlist = wishlistItemsLive.any((item) => item['name'] == name);
                    final isInCart = _isInCart(name);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: imageUrl.isNotEmpty
                                          ? Image.network(
                                              imageUrl,
                                              fit: BoxFit.contain,
                                              width: double.infinity,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: Colors.grey[100],
                                                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 60),
                                              ),
                                            )
                                          : Container(
                                              color: Colors.grey[100],
                                              child: const Icon(Icons.image, color: Colors.grey, size: 60),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => _toggleWishlist(product, wishlistItemsLive),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isInWishlist ? Colors.pinkAccent : Colors.white,
                                          border: Border.all(color: Colors.pinkAccent),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: Icon(
                                          Icons.favorite,
                                          color: isInWishlist ? Colors.white : Colors.pinkAccent,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Rs. $price",
                                        style: const TextStyle(
                                          color: Colors.pinkAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _toggleCart(product),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isInCart ? Colors.pinkAccent : Colors.white,
                                            border: Border.all(color: Colors.pinkAccent),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 16,
                                            color: isInCart ? Colors.white : Colors.pinkAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.baby_changing_station,
                    color: Colors.pinkAccent,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "BabyShop",
              style: GoogleFonts.comfortaa(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.pinkAccent,
        automaticallyImplyLeading: false,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("No new notifications 📱"),
                      backgroundColor: Colors.pinkAccent,
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoryScreen(category: {"name": "All Categories"})),
              );
            },
            icon: const Icon(Icons.category, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                style: GoogleFonts.comfortaa(),
                decoration: InputDecoration(
                  hintText: "Search for baby products... 🔍",
                  hintStyle: GoogleFonts.comfortaa(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.pinkAccent),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Banner Section
            _buildBannerSection(),
            const SizedBox(height: 24),
            
            // Categories Section
            _buildCategoriesSection(),
            const SizedBox(height: 24),
            
            // Testimonials Section
            _buildTestimonialsSection(),
            const SizedBox(height: 24),
            
            // Featured Products Section
            _buildFeaturedProducts(),
          ],
        ),
      ),
    );
  }
}