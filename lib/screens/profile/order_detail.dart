import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF121212);
    const Color accentYellow = Color(0xFFFFC107);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Order ${order["id"]}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Date: ${order["date"]}",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              "Status: ${order["status"]}",
              style: TextStyle(
                  color: order["status"] == "Delivered"
                      ? Colors.greenAccent
                      : accentYellow,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Ordered Items
            const Text(
              "Ordered Items",
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...order["items"].map<Widget>((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item["name"], style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  "Qty: ${item["qty"]}",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: Text(
                  "Rs ${item["price"]}",
                  style: const TextStyle(color: accentYellow),
                ),
              );
            }).toList(),
            const Divider(color: Colors.white24),

            // Total
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Total: Rs ${order["total"]}",
                style: const TextStyle(
                    color: accentYellow, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
