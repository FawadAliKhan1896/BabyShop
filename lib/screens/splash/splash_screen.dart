import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoScale;
  late Animation<double> _fadeText;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _fadeText = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = const Color.fromARGB(255, 255, 125, 240);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background gradient glow
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: [
                  Color.fromARGB(255, 255, 125, 240).withOpacity(0.08),
                  const Color.fromARGB(255, 255, 255, 255),
                ],
              ),
            ),
          ),

          // Animated glowing ring
          AnimatedBuilder(
            animation: _logoScale,
            builder: (context, child) {
              return Container(
                width: 320 * _logoScale.value,
                height: 320 * _logoScale.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      gold.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              );
            },
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FadeTransition(
                  opacity: _fadeText,
                  child: Column(
                    children: const [
                      Text(
                        "Baby Shop Hub",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 64, 255),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Everything Your Baby Needs, All in One Place",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(179, 0, 0, 0),
                          fontSize: 15,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                // Enlarged logo / image
                ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 255, 125, 240).withOpacity(0.4),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 320, // 👈 Bigger image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Button
                FadeTransition(
                  opacity: _fadeText,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: gold.withOpacity(0.5)),
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 255, 125, 240).withOpacity(0.8),
                          const Color.fromARGB(255, 239, 64, 255).withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 255, 143, 238).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                        shadowColor: const Color.fromARGB(0, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
