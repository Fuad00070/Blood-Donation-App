import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';
import '../../utils/location_data.dart';
import '../../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _selectedBloodGroup;
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  bool _isLoading = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  Future<void> _handleRegister() async {
    if (_fullNameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _selectedBloodGroup == null ||
        _selectedUpazila == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields including location")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // লোকেশন স্ট্রিং তৈরি (উদা: Mirpur, Dhaka, Dhaka)
      String fullLocation = "$_selectedUpazila, $_selectedDistrict, $_selectedDivision";

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': fullLocation,
        'division': _selectedDivision,
        'district': _selectedDistrict,
        'upazila': _selectedUpazila,
        'bloodGroup': _selectedBloodGroup,
        'profileImage': null,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Registration Failed")));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryRed))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Text("Create Account", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildTextField(controller: _fullNameController, hint: "Full Name", icon: Icons.person_outline),
            const SizedBox(height: 15),
            _buildTextField(controller: _emailController, hint: "Email", icon: Icons.email_outlined),
            const SizedBox(height: 15),
            _buildTextField(controller: _phoneController, hint: "Phone Number", icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 15),
            
            // Blood Group
            DropdownButtonFormField<String>(
              decoration: _inputDecoration("Select Blood Group", Icons.opacity),
              items: _bloodGroups.map((group) => DropdownMenuItem(value: group, child: Text(group))).toList(),
              onChanged: (value) => setState(() => _selectedBloodGroup = value),
            ),
            const SizedBox(height: 15),

            // Division
            DropdownButtonFormField<String>(
              decoration: _inputDecoration("Select Division", Icons.map_outlined),
              value: _selectedDivision,
              items: LocationData.bdLocation.keys.map((div) => DropdownMenuItem(value: div, child: Text(div))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedDivision = val;
                  _selectedDistrict = null;
                  _selectedUpazila = null;
                });
              },
            ),
            const SizedBox(height: 15),

            // District (Only shows if Division is selected)
            if (_selectedDivision != null)
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Select District", Icons.location_city),
                value: _selectedDistrict,
                items: LocationData.bdLocation[_selectedDivision]!.keys.map((dis) => DropdownMenuItem(value: dis, child: Text(dis))).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDistrict = val;
                    _selectedUpazila = null;
                  });
                },
              ),
            const SizedBox(height: 15),

            // Upazila (Only shows if District is selected)
            if (_selectedDistrict != null)
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Select Upazila", Icons.location_on_outlined),
                value: _selectedUpazila,
                items: LocationData.bdLocation[_selectedDivision]![_selectedDistrict]!.map((upa) => DropdownMenuItem(value: upa, child: Text(upa))).toList(),
                onChanged: (val) => setState(() => _selectedUpazila = val),
              ),
            const SizedBox(height: 15),

            _buildTextField(controller: _passwordController, hint: "Password", icon: Icons.lock_outline, isPassword: true),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Register", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryRed)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint, icon),
    );
  }
}
