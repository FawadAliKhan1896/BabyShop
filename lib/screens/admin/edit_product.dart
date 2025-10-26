import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AdminEditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const AdminEditProductScreen({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  _AdminEditProductScreenState createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  String? _imageUrl;
  String? _category;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  final List<String> categories = [
    "Smart Watches",
    "Sports Watches",
    "Luxury Watches",
    "Wrist Bands",
  ];

  final Color backgroundColor = const Color(0xFF1E1E1E);
  final Color accentYellow = const Color(0xFFFFC107);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productData['name']);
    _descController = TextEditingController(text: widget.productData['description']);
    _priceController =
        TextEditingController(text: widget.productData['price'].toString());
    _imageUrl = widget.productData['imageUrl'];
    _category = widget.productData['category'];
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder:
            const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentYellow)),
      );

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;

    setState(() => _isLoading = true);

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child('${widget.productId}.jpg');

      UploadTask uploadTask;

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        uploadTask = storageRef.putData(bytes);
      } else {
        uploadTask = storageRef.putFile(File(picked.path));
      }

      final snapshot = await uploadTask;
      final downloadURL = await snapshot.ref.getDownloadURL();

      setState(() => _imageUrl = downloadURL);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate() || _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select category")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'imageUrl': _imageUrl,
        'category': _category,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Product updated successfully!"),
          backgroundColor: accentYellow,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text("Edit Product", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image with glow
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accentYellow.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(_imageUrl!, height: 150),
                            )
                          : const Icon(Icons.image, color: Colors.white70, size: 100),
                      const SizedBox(height: 10),
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.amberAccent)
                          : ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.upload),
                              label: const Text("Change Image"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentYellow,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Name
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Product Name"),
                validator: (value) => value!.isEmpty ? "Enter product name" : null,
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Description"),
                validator: (value) => value!.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 20),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Price (Rs)"),
                validator: (value) => value!.isEmpty ? "Enter price" : null,
              ),
              const SizedBox(height: 20),

              // Category
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: Colors.grey[900],
                decoration: _inputDecoration("Select Category"),
                items: categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _category = val),
                validator: (value) => value == null ? "Select category" : null,
              ),
              const SizedBox(height: 30),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.amberAccent),
                      )
                    : ElevatedButton(
                        onPressed: _updateProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentYellow,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
