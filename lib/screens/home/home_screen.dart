import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../product/product_detail.dart';
import '../auth/login_screen.dart';

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

  String selectedFilter = "All";
  String searchQuery = "";

  final Color backgroundColor = const Color(0xFF1E1E1E);
  final Color cardColor = const Color(0xFF2B2B2B);
  final Color accentYellow = const Color(0xFFFFC107);

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _fetchCart();
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
        SnackBar(
          backgroundColor: accentYellow,
          content: const Text(
            "Removed from cart 🗑️",
            style: TextStyle(color: Colors.black),
          ),
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
        SnackBar(
          backgroundColor: accentYellow,
          content: const Text(
            "Added to cart 🛒",
            style: TextStyle(color: Colors.black),
          ),
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
        SnackBar(
          backgroundColor: accentYellow,
          content: const Text(
            "Removed from wishlist",
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    } else {
      wishlistItems.add(product);
      await docRef.set({'items': wishlistItems});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: accentYellow,
          content: const Text(
            "Added to wishlist",
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
    setState(() {});
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  Stream<List<Map<String, dynamic>>> getWishlistStream() {
    if (user == null) return const Stream.empty();
    return wishlistCollection.doc(user!.uid).snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data();
      return List<Map<String, dynamic>>.from(data?['items'] ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            children: [
              const TextSpan(text: "Baby "),
              TextSpan(
                text: "Shop",
                style: TextStyle(color: const Color.fromARGB(255, 244, 45, 251)),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search products...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black,
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                for (final filter in ["All", "Newest", "Low Price", "High Price"])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selectedFilter == filter,
                      selectedColor: accentYellow,
                      onSelected: (_) => setState(() => selectedFilter = filter),
                      labelStyle: TextStyle(
                        color: selectedFilter == filter
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: Colors.grey[850],
                    ),
                  ),
              ],
            ),
          ),

          // Products Grid
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
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
                        child: CircularProgressIndicator(color: Colors.yellow),
                      );
                    }

                    final allProducts = snapshot.data?.docs ?? [];
                    if (allProducts.isEmpty) {
                      return const Center(
                        child: Text("No products found",
                            style: TextStyle(color: Colors.white54)),
                      );
                    }

                    List<Map<String, dynamic>> productList =
                        allProducts.map((e) => e.data() as Map<String, dynamic>).toList();

                    // Search filter
                    productList = productList.where((data) =>
                        (data['name']?.toString().toLowerCase() ?? '')
                            .contains(searchQuery)).toList();

                    // Sorting filters
                    if (selectedFilter == "Low Price") {
                      productList.sort((a, b) =>
                          (a['price'] ?? 0).compareTo(b['price'] ?? 0));
                    } else if (selectedFilter == "High Price") {
                      productList.sort((a, b) =>
                          (b['price'] ?? 0).compareTo(a['price'] ?? 0));
                    } else if (selectedFilter == "Newest") {
                      productList.sort((a, b) {
                        final aTime = (a['createdAt'] ?? Timestamp.now()) as Timestamp;
                        final bTime = (b['createdAt'] ?? Timestamp.now()) as Timestamp;
                        return bTime.compareTo(aTime);
                      });
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: productList.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
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
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorBuilder: (_, __, ___) => Container(
                                                  color: Colors.grey[800],
                                                  child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 60),
                                                ),
                                              )
                                            : Container(
                                                color: Colors.grey[800],
                                                child: const Icon(Icons.image, color: Colors.white54, size: 60),
                                              ),
                                      ),
                                      // Wishlist Icon
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () => _toggleWishlist(product, wishlistItemsLive),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isInWishlist ? accentYellow : Colors.white,
                                              border: Border.all(color: accentYellow),
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            child: const Icon(Icons.favorite, color: Colors.black, size: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Rs $price",
                                                style: const TextStyle(
                                                  color: Colors.yellow,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Cart Icon
                                        GestureDetector(
                                          onTap: () => _toggleCart(product),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isInCart ? accentYellow : Colors.white,
                                              border: Border.all(color: accentYellow),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            child: const Icon(Icons.shopping_cart_outlined, size: 20, color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
