import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Colors.white;
    const Color cardColor = Colors.white;
    const Color accentPink = Colors.pinkAccent;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "About Us",
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
            left: -70,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.pinkAccent.withOpacity(0.12),
                    Colors.pinkAccent.withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 180,
            right: -50,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.shade100.withOpacity(0.15),
                    Colors.pink.shade50.withOpacity(0.08),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.pinkAccent.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 350,
            left: 50,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.pink.shade50.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: 40,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Baby Shop",
                    style: GoogleFonts.comfortaa(
                      color: accentPink,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Everything Your Baby Needs, All in One Place",
                    style: TextStyle(color: Colors.black54, fontSize: 13),
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
                    "About Baby Shop",
                    style: TextStyle(
                        color: accentPink,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Baby Shop is your trusted destination for premium baby products. "
                    "We offer everything your baby needs, from diapers and food to toys and care products, all in one convenient place.",
                    style: TextStyle(color: Colors.black87, height: 1.5),
                  ),
                  SizedBox(height: 20),

                  // Mission
                  Text(
                    "Our Mission",
                    style: TextStyle(
                        color: accentPink,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Our mission is to provide parents with high-quality baby products "
                    "that ensure safety, comfort, and happiness for their little ones. We aim to support families with trusted products.",
                    style: TextStyle(color: Colors.black87, height: 1.5),
                  ),
                  SizedBox(height: 20),

                  // Contact Info
                  Text(
                    "Contact Us",
                    style: TextStyle(
                        color: accentPink,
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
                      Icon(Icons.email, color: accentPink),
                      SizedBox(width: 10),
                      Text("support@babyshop.com",
                          style: TextStyle(color: Colors.black87)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.phone, color: accentPink),
                      SizedBox(width: 10),
                      Text("+92 312 5552565",
                          style: TextStyle(color: Colors.black87)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: accentPink),
                      SizedBox(width: 10),
                      Text("Karachi, Pakistan",
                          style: TextStyle(color: Colors.black87)),
                    ],
                  ),
                ],
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
