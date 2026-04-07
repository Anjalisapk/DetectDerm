import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  
  // Animation controller for logo fade in
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup fade animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Start animation
    _controller.forward();

    // Check internet then navigate
    Future.delayed(const Duration(seconds: 3), () {
      _checkInternetAndNavigate();
    });
  }

  // ── Check Internet ───────────────────────────
  Future<void> _checkInternetAndNavigate() async {
    try {
      // Try to connect to google
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // Online → Login Screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      //  Offline → Auto Guest → Home Screen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest', true);
      await prefs.remove('user_id');
      await prefs.setString('user_name', 'Guest');

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Green background
      backgroundColor: const Color(0xFF2E7D32),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // App icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  size: 70,
                  color: Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(height: 24),

              // App name
              const Text(
                'DetectDerm',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 8),

              // Tagline in Nepali
              const Text(
                'छाला रोग पहिचान प्रणाली',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 60),

              // Loading indicator
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),

              const SizedBox(height: 16),

              const Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}