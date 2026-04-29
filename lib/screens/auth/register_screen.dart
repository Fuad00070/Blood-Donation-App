import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Register as a new user",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            
            // Input Fields with icons as per the image
            _buildTextField(
              controller: _fullNameController,
              hint: "Full Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _emailController,
              hint: "Email",
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _phoneController,
              hint: "Phone Number",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _passwordController,
              hint: "Password",
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _confirmPasswordController,
              hint: "Confirm Password",
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            
            const SizedBox(height: 40),
            
            // Register Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Main screen after "registration"
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Register",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 25),
            
            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
        ),
      ),
    );
  }
}
