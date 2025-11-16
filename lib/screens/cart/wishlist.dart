import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../product/product_detail.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final wishlistCollection = FirebaseFirestore.instance.collection('wishlists');



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        elevation: 2,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "My Wishlist",
          style: GoogleFonts.comfortaa(
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
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            );
          }

          final wishlistData =
              snapshot.data?.data() as Map<String, dynamic>? ?? {'items': []};
          final itemsRaw = List<Map<String, dynamic>>.from(wishlistData['items']);
          final wishlistItems = {
            for (var item in itemsRaw) (item['name'] ?? DateTime.now().toString()): item
          }.values.toList();

          if (wishlistItems.isEmpty) {
            return Center(
              child: Text(
                "Your wishlist is empty",
                style: GoogleFonts.comfortaa(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            );
          }

          return Stack(
            children: [
              // Decorative Background
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 200,
                left: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              ListView.builder(
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.15),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.black54,
                                        size: 50,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 130,
                                    height: 130,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.black54,
                                      size: 50,
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
                                style: GoogleFonts.comfortaa(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.pinkAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Rs ${price.toStringAsFixed(0)}",
                                  style: GoogleFonts.comfortaa(
                                    color: Colors.pinkAccent,
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
                              color: Colors.red[400],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
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
            ),
            ],
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
        SnackBar(
          backgroundColor: Colors.pinkAccent,
          content: Text(
            "Removed from wishlist",
            style: GoogleFonts.comfortaa(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
  }
}
