import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cart/checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImage = 0;
  int _quantity = 1;
  final user = FirebaseAuth.instance.currentUser;
  final cartCollection = FirebaseFirestore.instance.collection('carts');
  final wishlistCollection = FirebaseFirestore.instance.collection('wishlists');

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    // 🔹 Product Images - FIXED
    List<String> productImages = [];

    final imagesField = product['images'];
    if (imagesField != null) {
      if (imagesField is List) {
        productImages = imagesField.map((e) => e.toString()).toList();
      } else if (imagesField is String && imagesField.isNotEmpty) {
        productImages = [imagesField];
      }
    }

    // Check for imageUrl (normal product) or image (wishlist)
    if (productImages.isEmpty) {
      if ((product['imageUrl'] ?? '').isNotEmpty) {
        productImages = [product['imageUrl']];
      } else if ((product['image'] ?? '').isNotEmpty) {
        productImages = [product['image']];
      }
    }

    // Default placeholder if no image
    if (productImages.isEmpty) {
      productImages = ['assets/images/default.png'];
    }

    final category = product['category'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          product["name"] ?? 'Unnamed',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Carousel
                CarouselSlider(
                  options: CarouselOptions(
                    height: 300,
                    autoPlay: productImages.length > 1,
                    enlargeCenterPage: true,
                    viewportFraction: 1,
                    onPageChanged: (index, _) {
                      setState(() => _currentImage = index);
                    },
                  ),
                  items: productImages.map((img) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: img.startsWith("http")
                          ? Image.network(img,
                              width: double.infinity, fit: BoxFit.contain)
                          : Image.asset(img, fit: BoxFit.contain),
                    );
                  }).toList(),
                ),

                if (productImages.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: productImages.asMap().entries.map((entry) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        height: 6,
                        width: _currentImage == entry.key ? 20 : 8,
                        decoration: BoxDecoration(
                          color: _currentImage == entry.key
                              ? Colors.yellow
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }).toList(),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product["name"] ?? 'Unnamed',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Rs ${product["price"] ?? 0}",
                        style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 22,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        product["description"] ??
                            "No description available for this product.",
                        style: const TextStyle(
                            color: Colors.white70, height: 1.5, fontSize: 15),
                      ),
                      const SizedBox(height: 25),
                      const Divider(color: Colors.white24),
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "You may also like",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      // 🔹 Similar Products
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .where('category', isEqualTo: category)
                            .limit(6)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.yellow));
                          }

                          final products = snapshot.data!.docs
                              .map((doc) => doc.data() as Map<String, dynamic>)
                              .where((p) => p['name'] != product['name'])
                              .toList();

                          if (products.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "No similar products found",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ),
                            );
                          }

                          return SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final item = products[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ProductDetailScreen(
                                                  product: item)),
                                    );
                                  },
                                  child: Container(
                                    width: 140,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(10)),
                                            child: Image.network(
                                              item['imageUrl'] ??
                                                  item['image'] ??
                                                  '',
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['name'] ?? '',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                "Rs ${item['price'] ?? 0}",
                                                style: const TextStyle(
                                                    color: Colors.yellow,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🟡 Floating Add to Cart + Quantity
          Positioned(
            bottom: 15,
            right: 15,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                children: [
                  // Quantity Selector
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 1.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.yellow),
                          onPressed: () {
                            if (_quantity > 1) {
                              setState(() => _quantity--);
                            }
                          },
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.yellow),
                          onPressed: () {
                            setState(() => _quantity++);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Add to Cart Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🛒 Add to Cart Function
  Future<void> _addToCart() async {
    if (user == null) return;
    final docRef = cartCollection.doc(user!.uid);
    final doc = await docRef.get();

    List<Map<String, dynamic>> items = [];
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      if (data.containsKey('items')) {
        items = List<Map<String, dynamic>>.from(data['items']);
      }
    }

    final index = items.indexWhere((i) => i['name'] == widget.product['name']);
    if (index != -1) {
      items[index]['qty'] = ((items[index]['qty'] as num) + _quantity).toInt();
    } else {
      items.add({
        'name': widget.product['name'],
        'price': (widget.product['price'] as num).toDouble(),
        'image': widget.product['imageUrl'] ?? widget.product['image'] ?? '',
        'qty': _quantity,
      });
    }

    await docRef.set({'items': items});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.yellow,
        content: Text(
          "${widget.product['name']} added to cart!",
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
