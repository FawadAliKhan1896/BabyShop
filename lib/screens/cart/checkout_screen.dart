import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final Color backgroundColor = const Color(0xFF121212);
  final Color accentYellow = const Color(0xFFFFC107);
  final Color textFieldBg = const Color(0xFF1F1F1F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Delivery Information",
                style: TextStyle(
                  color: Colors.white,
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

              const Text(
                "Payment Method",
                style: TextStyle(
                  color: Colors.white,
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
                        color: Color(0xFFFFC107),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _confirmOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentYellow,
                          foregroundColor: Colors.black,
                          shadowColor: accentYellow.withOpacity(0.5),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Confirm Order",
                          style: TextStyle(
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
    );
  }

  Widget _buildTextField(String label, IconData icon, Function(String?) onSaved,
      {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboard,
      decoration: InputDecoration(
        filled: true,
        fillColor: textFieldBg,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accentYellow),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) => value!.isEmpty ? "Please enter $label" : null,
      onSaved: onSaved,
    );
  }

  Widget _paymentOption(String value) {
    return RadioListTile(
      activeColor: accentYellow,
      title: Text(value, style: const TextStyle(color: Colors.white)),
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
