import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Privacy Policy",
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
            top: -50,
            left: -65,
            child: Container(
              width: 170,
              height: 170,
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
            top: 250,
            right: -45,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.shade100.withOpacity(0.18),
                    Colors.pink.shade50.withOpacity(0.1),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 40,
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.pink.shade50.withOpacity(0.35),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Positioned(
            top: 400,
            right: 60,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 250,
            left: -10,
            child: Container(
              width: 65,
              height: 65,
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
          SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy",
              style: TextStyle(
                color: Colors.pinkAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Last updated: October 2025",
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            SizedBox(height: 20),
            Text(
              "At Baby Shop, your privacy is our top priority. We are committed to protecting your personal data and being transparent about how we collect and use it.",
              style: TextStyle(color: Colors.black87, height: 1.6),
            ),
            SizedBox(height: 25),
            _sectionTitle("1. Information We Collect"),
            _sectionText(
              "We may collect information such as your name, email address, contact number, "
              "and purchase details when you create an account, place an order, or contact our support team.",
            ),
            SizedBox(height: 15),
            _sectionTitle("2. How We Use Your Data"),
            _sectionText(
              "Your data helps us process orders, improve user experience, send updates, and provide customer support. "
              "We never sell your personal information to third parties.",
            ),
            SizedBox(height: 15),
            _sectionTitle("3. Data Protection"),
            _sectionText(
              "We use industry-standard encryption and secure systems to protect your information from unauthorized access, alteration, or disclosure.",
            ),
            SizedBox(height: 15),
            _sectionTitle("4. Your Rights"),
            _sectionText(
              "You have the right to request access, correction, or deletion of your data at any time. "
              "You can contact us through our support email for such requests.",
            ),
            SizedBox(height: 15),
            _sectionTitle("5. Updates to Policy"),
            _sectionText(
              "We may update our privacy policy periodically. Please check this page regularly to stay informed about how we protect your data.",
            ),
            SizedBox(height: 30),
            Divider(color: Colors.grey.shade300),
            Center(
              child: Column(
                children: [
                  Text("For inquiries:", style: TextStyle(color: Colors.black87)),
                  SizedBox(height: 5),
                  Text("privacy@babyshop.com",
                      style: TextStyle(
                        color: Colors.pinkAccent,
                        fontWeight: FontWeight.bold,
                      )),
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          color: Colors.pinkAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold),
    );
  }

  Widget _sectionText(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.black87, height: 1.5),
    );
  }
}
