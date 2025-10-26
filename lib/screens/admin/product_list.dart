import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product.dart';
import 'edit_product.dart';

class AdminProductListScreen extends StatelessWidget {
  final CollectionReference productsRef =
      FirebaseFirestore.instance.collection('products');

  final Color backgroundColor = const Color(0xFF1E1E1E);
  final Color accentYellow = const Color(0xFFFFC107);

  // 🔹 Delete Product Function
  Future<void> _deleteProduct(BuildContext context, String docId) async {
    try {
      await productsRef.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Product deleted successfully"),
          backgroundColor: accentYellow,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text("Manage Products", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminAddProductScreen()),
              );
            },
            icon: const Icon(Icons.add, color: Colors.greenAccent),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No products found.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final data = product.data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminEditProductScreen(
                        productId: product.id,
                        productData: data,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accentYellow.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: data['imageUrl'] != null && data['imageUrl'] != ''
                          ? Image.network(
                              data['imageUrl'],
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image, color: Colors.white54, size: 55),
                    ),
                    title: Text(
                      data['name'] ?? 'No name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Rs ${data['price'] ?? 0}",
                      style: TextStyle(
                        color: accentYellow,
                        fontSize: 14,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteProduct(context, product.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
