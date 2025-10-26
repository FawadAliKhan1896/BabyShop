import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF121212); // body ke liye dark grey
    const Color cardColor = Color(0xFF1E1E1E); // content ke liye slightly lighter grey
    const Color accentYellow = Color(0xFFFFC107); // primary accent

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("About Us", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset("assets/images/watch.jpg", width: 120),
                  const SizedBox(height: 10),
                  const Text(
                    "WatchHub",
                    style: TextStyle(
                      color: accentYellow,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "STREAMLINE YOUR LIFE WITH TIMEFLOW",
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // About section
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "About WatchHub",
                    style: TextStyle(
                        color: accentYellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "WatchHub is your go-to destination for premium, stylish, and modern watches. "
                    "We bring together elegance and technology, offering a wide range of smart, luxury, and sports watches for every lifestyle.",
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  SizedBox(height: 20),

                  // Mission
                  Text(
                    "Our Mission",
                    style: TextStyle(
                        color: accentYellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Our mission is to provide customers with high-quality watches "
                    "that blend innovation, durability, and sophistication. We aim to redefine timekeeping through design and performance.",
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  SizedBox(height: 20),

                  // Contact Info
                  Text(
                    "Contact Us",
                    style: TextStyle(
                        color: accentYellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Contact Rows
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Row(
                    children: [
                      Icon(Icons.email, color: accentYellow),
                      SizedBox(width: 10),
                      Text("support@watchhub.com",
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.phone, color: accentYellow),
                      SizedBox(width: 10),
                      Text("+92 312 5552565",
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: accentYellow),
                      SizedBox(width: 10),
                      Text("Karachi, Pakistan",
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
