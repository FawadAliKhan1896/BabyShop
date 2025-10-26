import 'dart:io' show File;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  _AdminAddProductScreenState createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _description = '';
  double _price = 0;
  String? _imageUrl;
  String? _category;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  final List<String> categories = [
    "Baby Toys",
    "Baby Clothes",
    "Baby Accessories",
    "Baby Care Products",
  ];

  final String cloudName = "dkscvg8pg";
  final String uploadPreset = "image_create";

  final Color backgroundColor = const Color(0xFF1E1E1E);
  final Color cardColor = const Color(0xFF2B2B2B);
  final Color accentYellow = const Color(0xFFFFC107);

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    try {
      final uri =
          Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final data = json.decode(res.body);
        return data['secure_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      if (!kIsWeb) {
        final url = await uploadImageToCloudinary(File(picked.path));
        if (url != null) _imageUrl = url;
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _imageUrl == null || _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: accentYellow,
          content: const Text(
              "Please fill all fields, select category & upload image",
              style: TextStyle(color: Colors.black)),
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isUploading = true);

    try {
      await _firestore.collection('products').add({
        'name': _name,
        'description': _description,
        'price': _price,
        'imageUrl': _imageUrl,
        'category': _category,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder:
            const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: accentYellow)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text("Add Product", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Product Name"),
                validator: (v) => v!.isEmpty ? "Enter product name" : null,
                onSaved: (v) => _name = v!,
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Description"),
                validator: (v) => v!.isEmpty ? "Enter description" : null,
                onSaved: (v) => _description = v!,
              ),
              const SizedBox(height: 20),

              // Price
              TextFormField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Price (Rs)"),
                validator: (v) => v!.isEmpty ? "Enter price" : null,
                onSaved: (v) => _price = double.parse(v!),
              ),
              const SizedBox(height: 20),

              // Category Dropdown
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
                validator: (v) => v == null ? "Select category" : null,
              ),
              const SizedBox(height: 20),

              // Image Picker with Glow
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
                      _isUploading
                          ? const CircularProgressIndicator(color: Colors.amberAccent)
                          : ElevatedButton.icon(
                              onPressed: _pickImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentYellow,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.upload),
                              label: const Text("Upload Image"),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Add Product",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
