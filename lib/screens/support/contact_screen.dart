import 'package:flutter/material.dart';

class ContactSupportScreen extends StatelessWidget {
  final TextEditingController msgCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contact Support")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Write your message:", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            TextField(
              controller: msgCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Type your query here...",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Message sent!")),
                );
              },
              child: Text("Send"),
            )
          ],
        ),
      ),
    );
  }
}
