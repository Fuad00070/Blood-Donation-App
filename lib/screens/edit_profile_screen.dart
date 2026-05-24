import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  String? _selectedBloodGroup;
  
  File? _image;
  bool _isLoading = false;
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _locationController = TextEditingController(text: widget.userData['location']);
    _selectedBloodGroup = widget.userData['bloodGroup'];
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? imageUrl = widget.userData['profileImage'];

      if (_image != null) {
        // Upload image to Firebase Storage
        Reference ref = FirebaseStorage.instance.ref().child('profile_images').child('${user!.uid}.jpg');
        await ref.putFile(_image!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'bloodGroup': _selectedBloodGroup,
        'profileImage': imageUrl,
      });

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate update happened
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryRed))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _image != null 
                              ? FileImage(_image!) 
                              : (widget.userData['profileImage'] != null 
                                  ? NetworkImage(widget.userData['profileImage']) as ImageProvider
                                  : null),
                          child: (_image == null && widget.userData['profileImage'] == null)
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: AppColors.primaryRed,
                            radius: 20,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(_nameController, "Full Name", Icons.person_outline),
                    const SizedBox(height: 15),
                    _buildTextField(_phoneController, "Phone Number", Icons.phone_outlined, keyboardType: TextInputType.phone),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _selectedBloodGroup,
                      decoration: _inputDecoration("Blood Group", Icons.opacity),
                      items: _bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (val) => setState(() => _selectedBloodGroup = val),
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(_locationController, "Location (City)", Icons.location_on_outlined),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint, icon),
      validator: (val) => val!.isEmpty ? "Required" : null,
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
}
