import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../utils/constants.dart';
import 'register_screen.dart';
import '../../main.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Awesome Logo Representation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondaryRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bloodtype_rounded,
                  size: 80,
                  color: AppColors.primaryRed,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "BLOOD LINK",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: AppColors.primaryRed,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Every Drop Matters. Save a Life.",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 50),

              // Form Fields
              TextField(
                decoration: InputDecoration(
                  hintText: "Email Address",
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryRed),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryRed),
                  suffixIcon: const Icon(Icons.visibility_off_outlined, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Login Button
              CustomButton(
                text: "SIGN IN",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "New to Blood Link? ",
                    style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      "Register Now",
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
