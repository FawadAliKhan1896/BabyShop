import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Privacy Policy", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy",
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Last updated: October 2025",
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            SizedBox(height: 20),
            Text(
              "At WatchHub, your privacy is our top priority. We are committed to protecting your personal data and being transparent about how we collect and use it.",
              style: TextStyle(color: Colors.white70, height: 1.6),
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
            Divider(color: Colors.white24),
            Center(
              child: Column(
                children: [
                  Text("For inquiries:", style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 5),
                  Text("privacy@watchhub.com",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          color: Colors.greenAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold),
    );
  }

  Widget _sectionText(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white70, height: 1.5),
    );
  }
}
