import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Column(
          children: [
            Expanded(
              child: Image.asset(product.image, fit: BoxFit.cover),
            ),
            Text(product.name,
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text("\$${product.price.toStringAsFixed(0)}",
                style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
