import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Colors.white;
    const Color accentPink = Colors.pinkAccent;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Order ${order["id"]}",
          style: GoogleFonts.comfortaa(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Enhanced Decorative Background
          Positioned(
            top: -60,
            left: -55,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.pinkAccent.withOpacity(0.15),
                    Colors.pinkAccent.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -35,
            right: -45,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.shade100.withOpacity(0.18),
                    Colors.pink.shade50.withOpacity(0.1),
                  ],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: 25,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.pink.shade50.withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: 40,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.pinkAccent.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Date: ${order["date"]}",
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              "Status: ${order["status"]}",
              style: TextStyle(
                  color: order["status"] == "Delivered"
                      ? Colors.green
                      : accentPink,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Ordered Items
            const Text(
              "Ordered Items",
              style: TextStyle(
                  color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...order["items"].map<Widget>((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item["name"], style: const TextStyle(color: Colors.black)),
                subtitle: Text(
                  "Qty: ${item["qty"]}",
                  style: const TextStyle(color: Colors.black87),
                ),
                trailing: Text(
                  "Rs ${item["price"]}",
                  style: const TextStyle(color: accentPink),
                ),
              );
            }).toList(),
            Divider(color: Colors.grey.shade300),

            // Total
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Total: Rs ${order["total"]}",
                style: const TextStyle(
                    color: accentPink, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
          ),
        ],
      ),
    );
  }
}
