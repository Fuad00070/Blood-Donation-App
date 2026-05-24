import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import 'auth/login_screen.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    _checkUserStatus();
  }

  void _checkUserStatus() {
    Timer(const Duration(seconds: 3), () {
      // ফায়ারবেস অথেনটিকেশন চেক করা
      User? user = FirebaseAuth.instance.currentUser;
      
      if (mounted) {
        if (user != null) {
          // ইউজার লগইন করা থাকলে হোম স্ক্রিনে যাবে
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // লগইন না থাকলে লগইন স্ক্রিনে যাবে
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.secondaryRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryRed.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bloodtype_rounded,
                  size: 100,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _animation,
              child: Column(
                children: [
                  const Text(
                    "BLOOD LINK",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Donate Blood, Save Lives",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
