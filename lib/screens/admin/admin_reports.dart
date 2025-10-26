import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  final Color backgroundColor = const Color(0xFF1E1E1E);
  final Color accentYellow = const Color(0xFFFFC107);

  Future<Map<String, dynamic>> _fetchReportData() async {
    final ordersSnapshot =
        await FirebaseFirestore.instance.collection('orders').get();

    int totalOrders = ordersSnapshot.size;
    double totalRevenue = 0;
    Map<String, int> productSales = {};

    for (var order in ordersSnapshot.docs) {
      final data = order.data();
      totalRevenue += (data['totalAmount'] ?? 0).toDouble();

      final items =
          List<Map<String, dynamic>>.from(data['items'] ?? <Map<String, dynamic>>[]);

      for (var item in items) {
        final name = item['name']?.toString() ?? 'Unknown';
        final qty = int.tryParse(item['qty'].toString()) ?? 1;
        productSales[name] = (productSales[name] ?? 0) + qty;
      }
    }

    final topProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = topProducts.take(3).toList();

    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'topProducts': top3,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          "Reports & Analytics",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchReportData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                "No report data found.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final data = snapshot.data!;
          final topProducts = data['topProducts'] as List<MapEntry<String, int>>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCard(
                    "Total Orders", data['totalOrders'].toString(), Icons.shopping_bag),
                const SizedBox(height: 15),
                _buildStatCard(
                    "Total Revenue",
                    "Rs ${data['totalRevenue'].toStringAsFixed(0)}",
                    Icons.currency_rupee),
                const SizedBox(height: 25),
                const Text(
                  "🏆 Top Selling Products",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...topProducts.map((p) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: accentYellow.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(Icons.watch, color: accentYellow),
                      title: Text(p.key,
                          style: const TextStyle(color: Colors.white)),
                      trailing: Text("Sold: ${p.value}",
                          style: TextStyle(
                              color: accentYellow, fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
                if (topProducts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No sales data yet.",
                        style: TextStyle(color: Colors.white70)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: accentYellow.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: accentYellow, size: 28),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
