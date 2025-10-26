import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String name = '', email = '', password = '';
  bool _loading = false;

  Future<void> _signup() async {
    _formKey.currentState!.save();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _auth.currentUser!.updateDisplayName(name.trim());
      await _auth.currentUser!.reload();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account created successfully! Please login.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'weak-password') {
        message = "Password is too weak.";
      } else if (e.code == 'email-already-in-use') {
        message = "This email is already registered.";
      } else {
        message = e.message ?? "Signup failed.";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          // 🔹 Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 255, 228, 248), const Color.fromARGB(255, 255, 182, 249)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 255, 59, 242).withOpacity(0.3),
                        blurRadius: 25,
                        offset: Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔹 Logo/Title
                        Text(
                          "Baby Shop",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 255, 59, 226),
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Create your account now",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),

                        // 🔹 Name field
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: _inputDecoration(hint: "Full Name", icon: Icons.person),
                          onSaved: (value) => name = value ?? '',
                        ),
                        SizedBox(height: 20),

                        // 🔹 Email field
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: _inputDecoration(hint: "Email", icon: Icons.email),
                          onSaved: (value) => email = value ?? '',
                        ),
                        SizedBox(height: 20),

                        // 🔹 Password field
                        TextFormField(
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: _inputDecoration(hint: "Password", icon: Icons.lock),
                          onSaved: (value) => password = value ?? '',
                        ),
                        SizedBox(height: 30),

                        // 🔹 Signup button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: _loading
                              ? Center(child: CircularProgressIndicator(color: const Color.fromARGB(255, 255, 86, 224)))
                              : ElevatedButton(
                                  onPressed: _signup,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [const Color.fromARGB(255, 255, 173, 245), const Color.fromARGB(255, 255, 88, 208)],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: const Color.fromARGB(255, 255, 63, 252),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 25),

                        // 🔹 Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: TextStyle(color: const Color.fromARGB(179, 95, 95, 95)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => LoginScreen()),
                                );
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 255, 59, 242),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: const Color.fromARGB(137, 249, 127, 255)),
      filled: true,
      fillColor: const Color.fromARGB(255, 195, 195, 195),
      prefixIcon: Icon(icon, color: const Color.fromARGB(255, 255, 59, 229)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: const Color.fromARGB(255, 255, 59, 229), width: 2),
      ),
    );
  }
}
