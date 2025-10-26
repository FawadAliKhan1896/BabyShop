import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final cartCollection = FirebaseFirestore.instance.collection('carts');
  final wishlistCollection = FirebaseFirestore.instance.collection('wishlists');

  final Color accentYellow = const Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "My Cart 🛒",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: cartCollection.doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC107)),
            );
          }

          final cartData =
              snapshot.data?.data() as Map<String, dynamic>? ?? {'items': []};
          final List<Map<String, dynamic>> cartItems =
              List<Map<String, dynamic>>.from(cartData['items']);

          if (cartItems.isEmpty) {
            return const Center(
              child: Text(
                "Your cart is empty",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final total = cartItems.fold<double>(
            0.0,
            (sum, item) =>
                sum +
                ((item['price'] as num).toDouble() *
                    (item['qty'] as num).toDouble()),
          );

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 100), // space for button
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final image = item['image'] ?? item['imageUrl'] ?? '';
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: accentYellow.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                                child: image.toString().startsWith('http')
                                    ? Image.network(
                                        image,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/default.png',
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Rs ${(item['price'] as num).toDouble().toStringAsFixed(2)}",
                                        style: TextStyle(
                                          color: accentYellow,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              _qtyButton(item, -1),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  "${item['qty']}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              _qtyButton(item, 1),
                                            ],
                                          ),
                                          // Delete bottom right
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red[900],
                                            ),
                                            onPressed: () =>
                                                _removeItem(index, cartItems),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Wishlist top right
                          Positioned(
                            top: 5,
                            right: 5,
                            child: IconButton(
                              icon: Icon(
                                item['isWishlisted'] == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: accentYellow,
                              ),
                              onPressed: () =>
                                  _toggleWishlist(item, index, cartItems),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Floating Proceed Button
              Positioned(
                left: 20,
                right: 20,
                bottom: 90, // BottomNavigationBar ke upar
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [accentYellow.withOpacity(0.9), accentYellow],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentYellow.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckoutScreen(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Proceed to Checkout",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _qtyButton(Map<String, dynamic> item, int change) {
    return GestureDetector(
      onTap: () => _updateQty(item, change),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFFC107),
        ),
        padding: const EdgeInsets.all(5),
        child: Icon(
          change > 0 ? Icons.add : Icons.remove,
          size: 18,
          color: Colors.black,
        ),
      ),
    );
  }

  Future<void> _updateQty(Map<String, dynamic> item, int change) async {
    final docRef = cartCollection.doc(user!.uid);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final items = List<Map<String, dynamic>>.from(doc['items']);
    final index = items.indexWhere((i) => i['name'] == item['name']);
    if (index == -1) return;

    items[index]['qty'] =
        ((items[index]['qty'] as num) + change).clamp(1, double.infinity).toInt();

    await docRef.set({'items': items});
  }

  Future<void> _removeItem(int index, List<Map<String, dynamic>> items) async {
    items.removeAt(index);
    await cartCollection.doc(user!.uid).set({'items': items});
  }

  Future<void> _toggleWishlist(
      Map<String, dynamic> item, int index, List<Map<String, dynamic>> items) async {
    final wishlistRef = wishlistCollection.doc(user!.uid);
    final wishlistDoc = await wishlistRef.get();

    List<Map<String, dynamic>> wishlistItems = [];
    if (wishlistDoc.exists) {
      wishlistItems = List<Map<String, dynamic>>.from(wishlistDoc['items']);
    }

    final alreadyInWishlist =
        wishlistItems.any((w) => w['name'] == item['name']);

    if (alreadyInWishlist) {
      wishlistItems.removeWhere((w) => w['name'] == item['name']);
      items[index]['isWishlisted'] = false;
    } else {
      wishlistItems.add(item);
      items[index]['isWishlisted'] = true;
    }

    await wishlistRef.set({'items': wishlistItems});
    await cartCollection.doc(user!.uid).set({'items': items});
  }
}
