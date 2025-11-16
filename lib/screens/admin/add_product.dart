import 'dart:io' show File;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

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
          backgroundColor: Colors.pinkAccent,
          content: Text(
            "Please fill all fields, select category & upload image",
            style: GoogleFonts.comfortaa(color: Colors.white),
          ),
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
        labelStyle: GoogleFonts.comfortaa(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.pinkAccent),
          borderRadius: BorderRadius.circular(10),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(
          "Add Product",
          style: GoogleFonts.comfortaa(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
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
            bottom: -60,
            left: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.shade100.withOpacity(0.15),
                    Colors.pink.shade50.withOpacity(0.08),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    style: GoogleFonts.comfortaa(color: Colors.black87),
                    decoration: _inputDecoration("Product Name"),
                    validator: (v) => v!.isEmpty ? "Enter product name" : null,
                    onSaved: (v) => _name = v!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    maxLines: 3,
                    style: GoogleFonts.comfortaa(color: Colors.black87),
                    decoration: _inputDecoration("Description"),
                    validator: (v) => v!.isEmpty ? "Enter description" : null,
                    onSaved: (v) => _description = v!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.comfortaa(color: Colors.black87),
                    decoration: _inputDecoration("Price (Rs)"),
                    validator: (v) => v!.isEmpty ? "Enter price" : null,
                    onSaved: (v) => _price = double.parse(v!),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _category,
                    dropdownColor: Colors.white,
                    decoration: _inputDecoration("Select Category"),
                    items: categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat, style: GoogleFonts.comfortaa(color: Colors.black87)),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _category = val),
                    validator: (v) => v == null ? "Select category" : null,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        _imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(_imageUrl!, height: 150),
                              )
                            : const Icon(Icons.image, color: Colors.black54, size: 100),
                        const SizedBox(height: 10),
                        _isUploading
                            ? const CircularProgressIndicator(color: Colors.pinkAccent)
                            : ElevatedButton.icon(
                                onPressed: _pickImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pinkAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.upload),
                                label: Text("Upload Image", style: GoogleFonts.comfortaa()),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Add Product",
                        style: GoogleFonts.comfortaa(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
}