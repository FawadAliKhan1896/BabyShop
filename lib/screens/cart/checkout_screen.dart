import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? product; // For "Buy Now"

  const CheckoutScreen({super.key, this.product});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;
  final cartCollection = FirebaseFirestore.instance.collection('carts');
  final ordersCollection = FirebaseFirestore.instance.collection('orders');

  String fullName = "";
  String address = "";
  String city = "";
  String phone = "";
  String paymentMethod = "Cash on Delivery";

  bool isLoading = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Checkout",
          style: GoogleFonts.comfortaa(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative Background
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                "Delivery Information",
                style: GoogleFonts.comfortaa(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildTextField("Full Name", Icons.person, (val) => fullName = val!),
              const SizedBox(height: 15),
              _buildTextField("Address", Icons.home, (val) => address = val!),
              const SizedBox(height: 15),
              _buildTextField("City", Icons.location_city, (val) => city = val!),
              const SizedBox(height: 15),
              _buildTextField(
                "Phone Number",
                Icons.phone,
                (val) => phone = val!,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 25),

              Text(
                "Payment Method",
                style: GoogleFonts.comfortaa(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _paymentOption("Cash on Delivery"),
              _paymentOption("Credit / Debit Card"),
              _paymentOption("EasyPaisa / JazzCash"),
              const SizedBox(height: 40),

              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.pinkAccent,
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _confirmOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.pinkAccent.withOpacity(0.5),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Confirm Order",
                          style: GoogleFonts.comfortaa(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, Function(String?) onSaved,
      {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      style: GoogleFonts.comfortaa(color: Colors.black87),
      keyboardType: keyboard,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        labelText: label,
        labelStyle: GoogleFonts.comfortaa(color: Colors.black54),
        prefixIcon: Icon(icon, color: Colors.pinkAccent),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.pinkAccent),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) => value!.isEmpty ? "Please enter $label" : null,
      onSaved: onSaved,
    );
  }

  Widget _paymentOption(String value) {
    return RadioListTile(
      activeColor: Colors.pinkAccent,
      title: Text(
        value,
        style: GoogleFonts.comfortaa(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: value,
      groupValue: paymentMethod,
      onChanged: (val) {
        setState(() => paymentMethod = val.toString());
      },
    );
  }

  Future<void> _confirmOrder() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isLoading = true);

    try {
      List<Map<String, dynamic>> orderItems = [];
      double totalAmount = 0;

      if (widget.product != null) {
        orderItems = [widget.product!];
        totalAmount =
            (widget.product!['price'] as num).toDouble() * ((widget.product!['qty'] ?? 1) as num).toDouble();
      } else {
        final cartDoc = await cartCollection.doc(user!.uid).get();

        if (!cartDoc.exists || cartDoc['items'].isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Your cart is empty!"),
              backgroundColor: Colors.redAccent,
            ),
          );
          setState(() => isLoading = false);
          return;
        }

        orderItems = List<Map<String, dynamic>>.from(cartDoc['items']);
        totalAmount = orderItems.fold<double>(
          0.0,
          (sum, item) => sum +
              ((item['price'] as num).toDouble() * (item['qty'] as num).toDouble()),
        );
      }

      final orderData = {
        'userId': user!.uid,
        'fullName': fullName,
        'address': address,
        'city': city,
        'phone': phone,
        'paymentMethod': paymentMethod,
        'items': orderItems,
        'total': totalAmount,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Pending',
      };

      await ordersCollection.add(orderData);

      if (widget.product == null) {
        await cartCollection.doc(user!.uid).set({'items': []});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order Placed Successfully"),
          backgroundColor: Colors.greenAccent,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
