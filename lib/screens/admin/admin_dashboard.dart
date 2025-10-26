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

  final Color backgroundColor = const Color(0xFF1E1E1E);
  final Color cardColor = const Color(0xFF2B2B2B);
  final Color accentYellow = const Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "Logout",
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<List<int>>(
        future: Future.wait([_getProductCount(), _getOrderCount()]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.yellow));
          }

          final productCount = snapshot.data![0];
          final orderCount = snapshot.data![1];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome, Admin",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Dashboard Summary
                Row(
                  children: [
                    _buildStatCard(
                        "Total Products", productCount.toString(), Icons.watch),
                    const SizedBox(width: 20),
                    _buildStatCard(
                        "Total Orders", orderCount.toString(), Icons.receipt_long),
                  ],
                ),
                const SizedBox(height: 30),

                // Admin Actions
                Expanded(
                  child: ListView(
                    children: [
                      _buildActionTile(
                        context,
                        Icons.add_box,
                        "Add New Product",
                        const AdminAddProductScreen(),
                      ),
                      _buildActionTile(
                        context,
                        Icons.list_alt,
                        "Manage Products",
                        AdminProductListScreen(),
                      ),
                      _buildActionTile(
                        context,
                        Icons.receipt_long_outlined,
                        "View Orders",
                        const AdminOrdersScreen(),
                      ),
                      _buildActionTile(
                        context,
                        Icons.analytics_outlined,
                        "View Reports & Analytics",
                        const AdminReportsScreen(),
                      ),
                      const SizedBox(height: 20),

                      // Logout Card
                      Card(
                        color: Colors.redAccent.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading:
                              const Icon(Icons.logout, color: Colors.redAccent),
                          title: const Text(
                            "Logout",
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () => _logout(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accentYellow, size: 32),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
      BuildContext context, IconData icon, String title, Widget? screen) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: accentYellow),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: Colors.white70, size: 18),
        onTap: screen == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => screen),
                );
              },
      ),
    );
  }
}
