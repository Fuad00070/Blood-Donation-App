import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../utils/constants.dart';
import '../../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? selectedGroup;
  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryRed),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Join the Life-Saving Mission",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Register as a donor or request blood easily.",
              style: TextStyle(color: AppColors.textGrey, fontSize: 16),
            ),
            const SizedBox(height: 30),

            _buildTextField(
              label: "Full Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: "Email Address",
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: "Select Blood Group",
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.opacity, color: AppColors.primaryRed),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              items: bloodGroups.map((group) {
                return DropdownMenuItem(value: group, child: Text(group));
              }).toList(),
              onChanged: (value) => setState(() => selectedGroup = value),
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: "Phone Number",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: "Location (City)",
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: "Password",
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 40),

            CustomButton(
              text: "CREATE ACCOUNT",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already a member? ", style: TextStyle(color: AppColors.textGrey)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(icon, color: AppColors.primaryRed),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
