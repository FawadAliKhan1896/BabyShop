import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../auth/login_screen.dart';
import 'edit_profile.dart';
import 'order_history.dart';
import 'about_screen.dart';
import 'privacy_screen.dart';
import '../admin/admin_dashboard.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  User? user;
  bool _isUploading = false;

  // Colors
  final Color backgroundColor = const Color(0xFF1E1E1E);
  final Color cardColor = const Color(0xFF2B2B2B);
  final Color accentYellow = const Color(0xFFFFC107);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    await _auth.currentUser?.reload();
    setState(() {
      user = _auth.currentUser;
    });
  }

  // 🔹 Cloudinary Upload Function
  Future<String?> uploadToCloudinary(XFile pickedFile) async {
    final cloudName = "dkscvg8pg"; // replace
    final uploadPreset = "profile_image"; // create in Cloudinary

    String uploadUrl = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['upload_preset'] = uploadPreset;

      if (kIsWeb) {
        var bytes = await pickedFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: pickedFile.name));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = json.decode(respStr);

      if (response.statusCode == 200) {
        return data['secure_url']; // Cloudinary URL
      } else {
        print("Cloudinary Upload Error: $data");
        return null;
      }
    } catch (e) {
      print("Error uploading to Cloudinary: $e");
      return null;
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile == null) return;
    setState(() => _isUploading = true);

    try {
      String? imageUrl = await uploadToCloudinary(pickedFile);

      if (imageUrl != null) {
        await user!.updatePhotoURL(imageUrl);
        await user!.reload();
        await _loadUser();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Profile picture updated!"),
              backgroundColor: accentYellow,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to upload image to Cloudinary."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.yellow),
        ),
      );
    }

    final String displayName = user!.displayName ?? "User";
    final String email = user!.email ?? "";

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _isUploading
                          ? null
                          : (user!.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : const AssetImage("assets/images/profile.jpg")) as ImageProvider,
                    ),
                    if (_isUploading)
                      const Positioned.fill(
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.yellow),
                        ),
                      ),
                    if (!_isUploading)
                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: accentYellow,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accentYellow.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.camera_alt, size: 22, color: Colors.black),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // 🔹 Profile Options
          _buildOption(Icons.edit, "Edit Profile", EditProfileScreen()),
          _buildOption(Icons.history, "Order History", OrderHistoryScreen()),
          _buildOption(Icons.info_outline, "About Us", AboutUsScreen()),
          _buildOption(Icons.privacy_tip_outlined, "Privacy Policy", PrivacyPolicyScreen()),

          if (email == "admin@gmail.com")
            _buildOption(Icons.dashboard, "Admin Dashboard", const AdminDashboardScreen()),

          const SizedBox(height: 25),

          // 🔹 Logout Button (Dark Red, no glow)
          Container(
            decoration: BoxDecoration(
              color: Colors.red[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, Widget screen) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: accentYellow.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: accentYellow),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((value) {
            if (value == true) _loadUser();
          });
        },
      ),
    );
  }
}
