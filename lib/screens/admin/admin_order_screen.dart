import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  final Color backgroundColor = const Color(0xFF1E1E1E);
  final Color accentYellow = const Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Manage Orders", style: TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('total', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.greenAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No orders found.",
                  style: TextStyle(color: Colors.white70)),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Order Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("#${doc.id}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          Text(order["fullName"] ?? "",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Phone: ${order["phone"] ?? ""}",
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                      Text("Payment: ${order["paymentMethod"] ?? ""}",
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                      const Divider(color: Colors.white12, height: 20),

                      // 🔹 Order Items
                      ...items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(item["name"] ?? "",
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                              ),
                              Text("x${item["qty"] ?? 1}",
                                  style: const TextStyle(color: Colors.white54)),
                              Text("Rs ${item["price"] ?? 0}",
                                  style: TextStyle(
                                      color: accentYellow,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(color: Colors.white12, height: 20),

                      // 🔹 Total + Status Dropdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total: Rs ${order["total"] ?? 0}",
                              style: TextStyle(
                                  color: accentYellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          DropdownButton<String>(
                            dropdownColor: Colors.grey[850],
                            value: currentStatus,
                            style: const TextStyle(color: Colors.white),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.white),
                            items: const [
                              DropdownMenuItem(
                                  value: "Pending", child: Text("Pending")),
                              DropdownMenuItem(
                                  value: "Shipped", child: Text("Shipped")),
                              DropdownMenuItem(
                                  value: "Delivered", child: Text("Delivered")),
                              DropdownMenuItem(
                                  value: "Cancelled", child: Text("Cancelled")),
                            ],
                            onChanged: (newStatus) async {
                              if (newStatus != null) {
                                await FirebaseFirestore.instance
                                    .collection('orders')
                                    .doc(doc.id)
                                    .update({'status': newStatus});

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text("Status updated to $newStatus"),
                                    backgroundColor: Colors.green,
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
          );
        },
      ),
    );
  }
}
