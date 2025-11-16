import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  Future<Map<String, dynamic>> _fetchReportData() async {
    final ordersSnapshot =
        await FirebaseFirestore.instance.collection('orders').get();

    int totalOrders = ordersSnapshot.size;
    double totalRevenue = 0;
    Map<String, int> productSales = {};

    for (var order in ordersSnapshot.docs) {
      final data = order.data();
      totalRevenue += (data['total'] ?? 0).toDouble();

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(
          "Reports & Analytics",
          style: GoogleFonts.comfortaa(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchReportData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                "No report data found.",
                style: GoogleFonts.comfortaa(color: Colors.black54),
              ),
            );
          }

          final data = snapshot.data!;
          final topProducts = data['topProducts'] as List<MapEntry<String, int>>;

          return Stack(
            children: [
              Positioned(
                top: -80,
                right: -80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.pinkAccent.withOpacity(0.1),
                        Colors.pinkAccent.withOpacity(0.03),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                left: -60,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.pink.shade100.withOpacity(0.12),
                        Colors.pink.shade50.withOpacity(0.06),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SingleChildScrollView(
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
                    Text(
                      "🏆 Top Selling Products",
                      style: GoogleFonts.comfortaa(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...topProducts.map((p) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.15),
                              blurRadius: 6,
                              spreadRadius: 1,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.baby_changing_station, color: Colors.pinkAccent),
                          title: Text(p.key,
                              style: GoogleFonts.comfortaa(color: Colors.black87)),
                          trailing: Text("Sold: ${p.value}",
                              style: GoogleFonts.comfortaa(
                                  color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                        ),
                      );
                    }).toList(),
                    if (topProducts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text("No sales data yet.",
                            style: GoogleFonts.comfortaa(color: Colors.black54)),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.15),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: Colors.pinkAccent, size: 28),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.comfortaa(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(title,
                  style: GoogleFonts.comfortaa(color: Colors.black54, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}