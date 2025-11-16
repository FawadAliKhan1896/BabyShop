import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../product/product_detail.dart';

class CategoryScreen extends StatefulWidget {
  final Map<String, dynamic> category;
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final wishlistCollection = FirebaseFirestore.instance.collection('wishlists');
  List<Map<String, dynamic>> wishlistItems = [];
  String selectedFilter = "All";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    final doc = await wishlistCollection.doc(user!.uid).get();
    if (doc.exists) {
      final data = doc.data();
      setState(() {
        wishlistItems = List<Map<String, dynamic>>.from(data?['items'] ?? []);
      });
    }
  }

  bool _isInWishlist(String productName) {
    return wishlistItems.any((item) => item['name'] == productName);
  }

  Future<void> _toggleWishlist(Map<String, dynamic> product) async {
    final productName = product['name'];
    final docRef = wishlistCollection.doc(user!.uid);

    if (_isInWishlist(productName)) {
      wishlistItems.removeWhere((item) => item['name'] == productName);
      await docRef.set({'items': wishlistItems});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pinkAccent,
          content: Text("Removed from wishlist 💔",
              style: TextStyle(color: Colors.white)),
        ),
      );
    } else {
      wishlistItems.add(product);
      await docRef.set({'items': wishlistItems});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pinkAccent,
          content: Text("Added to wishlist ❤️",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.category["name"]?.toString() ?? "Unnamed";

    final List<Color> bgColors = [
      Colors.pinkAccent.shade100,
      Colors.pinkAccent.shade200,
      Colors.pinkAccent.shade100,
      Colors.pinkAccent.shade200,
      Colors.pinkAccent.shade100,
      Colors.pinkAccent.shade200,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search products...",
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.search, color: Colors.pinkAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🧭 Filter Buttons
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
                      selectedColor: Colors.pinkAccent,
                      onSelected: (_) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                      labelStyle: TextStyle(
                        color: selectedFilter == filter
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
              ],
            ),
          ),

          // 🛍️ Products Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('category', isEqualTo: name)
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
                    child: Text(
                      "No products found",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  );
                }

                // convert & filter by search
                List<Map<String, dynamic>> productList = allProducts
                    .map((e) => e.data() as Map<String, dynamic>)
                    .where((data) {
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  return name.contains(searchQuery);
                }).toList();

                // ✅ Safe sorting logic
                if (selectedFilter == "Newest") {
                  productList.sort((a, b) {
                    final aDate = a['createdAt'] is Timestamp
                        ? (a['createdAt'] as Timestamp).toDate()
                        : DateTime(2000);
                    final bDate = b['createdAt'] is Timestamp
                        ? (b['createdAt'] as Timestamp).toDate()
                        : DateTime(2000);
                    return bDate.compareTo(aDate);
                  });
                } else if (selectedFilter == "Low Price") {
                  productList.sort((a, b) {
                    final aPrice = double.tryParse(a['price'].toString()) ?? 0;
                    final bPrice = double.tryParse(b['price'].toString()) ?? 0;
                    return aPrice.compareTo(bPrice);
                  });
                } else if (selectedFilter == "High Price") {
                  productList.sort((a, b) {
                    final aPrice = double.tryParse(a['price'].toString()) ?? 0;
                    final bPrice = double.tryParse(b['price'].toString()) ?? 0;
                    return bPrice.compareTo(aPrice);
                  });
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: productList.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final product = productList[index];
                    final color = bgColors[index % bgColors.length];
                    final imageUrl = product['imageUrl'] ?? '';
                    final productName = product['name'] ?? 'Unnamed';
                    final price = product['price'] ?? '0';
                    final isInWishlist = _isInWishlist(productName);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Card(
                        color: color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(18)),
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white54,
                                        size: 60,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          productName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Rs $price",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _toggleWishlist({
                                  'name': productName,
                                  'price': price,
                                  'image': imageUrl,
                                }),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    isInWishlist
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 20,
                                    color: isInWishlist
                                        ? Colors.redAccent
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
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
