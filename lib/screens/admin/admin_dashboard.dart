import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_screen.dart';
import 'product_list.dart';
import 'add_product.dart';
import 'admin_order_screen.dart';
import 'admin_reports.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<int> _getProductCount() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    return snapshot.size;
  }

  Future<int> _getOrderCount() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('orders').get();
    return snapshot.size;
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  backgroundColor: Colors.white,
  appBar: AppBar(
    title: const Text("Admin Dashboard"),
    backgroundColor: Colors.pinkAccent,
    actions: [
      IconButton(
        icon: const Icon(Icons.logout, color: Colors.white),
        onPressed: () => _logout(context),
      ),
    ],
  ),
  body: FutureBuilder<List<int>>(

        future: Future.wait([_getProductCount(), _getOrderCount()]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent));
          }

          final productCount = snapshot.data![0];
          final orderCount = snapshot.data![1];

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildDashboardTile(
                  icon: Icons.shopping_bag,
                  label: "Manage Products",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AdminProductListScreen()),
                    );
                  },
                ),
                _buildDashboardTile(
                  icon: Icons.add_box,
                  label: "Add Product",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminAddProductScreen()),
                    );
                  },
                ),
                _buildDashboardTile(
                  icon: Icons.receipt_long,
                  label: "View Orders",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminOrdersScreen()),
                    );
                  },
                ),
                _buildDashboardTile(
                  icon: Icons.analytics,
                  label: "Reports",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminReportsScreen()),
                    );
                  },
                ),

                // Product Count
                _buildStatTile(
                  icon: Icons.inventory_2,
                  label: "Products",
                  value: productCount.toString(),
                ),

                // Order Count
                _buildStatTile(
                  icon: Icons.shopping_cart,
                  label: "Orders",
                  value: orderCount.toString(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.pinkAccent.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 50),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Stat boxes same design but different style
  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      color: Colors.pinkAccent.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 45),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
