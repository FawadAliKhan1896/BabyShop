import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {"q": "How to order?", "a": "Browse watches, add to cart, and checkout."},
    {"q": "Do you provide warranty?", "a": "Yes, all watches come with 2 years warranty."},
    {"q": "How to track my order?", "a": "Go to profile > Order History."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FAQs")),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(faqs[index]["q"]!),
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(faqs[index]["a"]!),
              ),
            ],
          );
        },
      ),
    );
  }
}
