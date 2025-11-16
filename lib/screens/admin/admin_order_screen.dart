import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(
          "Manage Orders",
          style: GoogleFonts.comfortaa(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('total', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No orders found.",
                style: GoogleFonts.comfortaa(color: Colors.black54),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return Stack(
            children: [
              Positioned(
                top: -70,
                right: -70,
                child: Container(
                  width: 180,
                  height: 180,
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
                bottom: -50,
                left: -50,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.pink.shade100.withOpacity(0.12),
                        Colors.pink.shade50.withOpacity(0.06),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final doc = orders[index];
                  final order = doc.data() as Map<String, dynamic>;
                  final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
                  final currentStatus = order['status'] ?? "Pending";

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("#${doc.id}",
                                  style: GoogleFonts.comfortaa(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Text(order["fullName"] ?? "",
                                  style: GoogleFonts.comfortaa(
                                      color: Colors.black54, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("Phone: ${order["phone"] ?? ""}",
                              style: GoogleFonts.comfortaa(
                                  color: Colors.black54, fontSize: 12)),
                          Text("Payment: ${order["paymentMethod"] ?? ""}",
                              style: GoogleFonts.comfortaa(
                                  color: Colors.black54, fontSize: 12)),
                          Divider(color: Colors.grey.shade300, height: 20),
                          ...items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(item["name"] ?? "",
                                        style: GoogleFonts.comfortaa(
                                            color: Colors.black54, fontSize: 13)),
                                  ),
                                  Text("x${item["qty"] ?? 1}",
                                      style: GoogleFonts.comfortaa(color: Colors.black54)),
                                  Text("Rs ${item["price"] ?? 0}",
                                      style: GoogleFonts.comfortaa(
                                          color: Colors.pinkAccent,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            );
                          }).toList(),
                          Divider(color: Colors.grey.shade300, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total: Rs ${order["total"] ?? 0}",
                                  style: GoogleFonts.comfortaa(
                                      color: Colors.pinkAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              DropdownButton<String>(
                                dropdownColor: Colors.white,
                                value: currentStatus,
                                style: GoogleFonts.comfortaa(color: Colors.black87),
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.black54),
                                items: [
                                  DropdownMenuItem(
                                      value: "Pending", 
                                      child: Text("Pending", style: GoogleFonts.comfortaa(color: Colors.black87))),
                                  DropdownMenuItem(
                                      value: "Shipped", 
                                      child: Text("Shipped", style: GoogleFonts.comfortaa(color: Colors.black87))),
                                  DropdownMenuItem(
                                      value: "Delivered", 
                                      child: Text("Delivered", style: GoogleFonts.comfortaa(color: Colors.black87))),
                                  DropdownMenuItem(
                                      value: "Cancelled", 
                                      child: Text("Cancelled", style: GoogleFonts.comfortaa(color: Colors.black87))),
                                ],
                                onChanged: (newStatus) async {
                                  if (newStatus != null) {
                                    await FirebaseFirestore.instance
                                        .collection('orders')
                                        .doc(doc.id)
                                        .update({'status': newStatus});

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Status updated to $newStatus",
                                          style: GoogleFonts.comfortaa(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.pinkAccent,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
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
}