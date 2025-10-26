import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../product/product_detail.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final wishlistCollection = FirebaseFirestore.instance.collection('wishlists');

  final Color backgroundColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1F1F1F);
  final Color accentYellow = const Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          "My Wishlist",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: wishlistCollection.doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC107)),
            );
          }

          final wishlistData =
              snapshot.data?.data() as Map<String, dynamic>? ?? {'items': []};
          final itemsRaw = List<Map<String, dynamic>>.from(wishlistData['items']);
          final wishlistItems = {
            for (var item in itemsRaw) (item['name'] ?? DateTime.now().toString()): item
          }.values.toList();

          if (wishlistItems.isEmpty) {
            return const Center(
              child: Text(
                "Your wishlist is empty",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              final item = wishlistItems[index];
              final image = item['image'] ?? item['imageUrl'] ?? '';
              final name = item['name'] ?? 'Unnamed Product';
              final price = double.tryParse(item['price'].toString()) ?? 0;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: item),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      // Yellow glow behind card
                      BoxShadow(
                        color: accentYellow.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Product Image with gradient overlay
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            image.isNotEmpty
                                ? Image.network(
                                    image,
                                    key: ValueKey(name),
                                    width: 130,
                                    height: 130,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 130,
                                      height: 130,
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white54,
                                        size: 50,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 130,
                                    height: 130,
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.white54,
                                      size: 50,
                                    ),
                                  ),
                            // Gradient overlay
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black54, Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Price tag with yellow background
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: accentYellow.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Rs ${price.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Delete Button with dark red background
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () => _removeItem(item),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red[800], // Dark red background
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 26,
                            ),
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
      ),
    );
  }

  Future<void> _removeItem(Map<String, dynamic> item) async {
    final doc = await wishlistCollection.doc(user!.uid).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final List<Map<String, dynamic>> items =
        List<Map<String, dynamic>>.from(data['items'] ?? []);
    items.removeWhere((e) => e['name'] == item['name']);

    await wishlistCollection.doc(user!.uid).set({'items': items});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Removed from wishlist",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}
