import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../utils/location_data.dart';
import '../profile_logic.dart';

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
  
  String? _selectedBloodGroup;
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  DateTime? _lastDonationDate;
  
  XFile? _image;
  bool _isLoading = false;
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _selectedBloodGroup = widget.userData['bloodGroup'];
    _selectedDivision = widget.userData['division'];
    _selectedDistrict = widget.userData['district'];
    _selectedUpazila = widget.userData['upazila'];
    
    if (widget.userData['lastDonationDate'] != null) {
      _lastDonationDate = (widget.userData['lastDonationDate'] as Timestamp).toDate();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = pickedFile);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastDonationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryRed),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _lastDonationDate) {
      setState(() => _lastDonationDate = picked);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _selectedUpazila == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select full location")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await ProfileLogic.updateFullProfile(
        userId: user.uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        location: "$_selectedUpazila, $_selectedDistrict",
        bloodGroup: _selectedBloodGroup,
        imageFile: _image,
      );

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'division': _selectedDivision,
        'district': _selectedDistrict,
        'upazila': _selectedUpazila,
        'lastDonationDate': _lastDonationDate != null ? Timestamp.fromDate(_lastDonationDate!) : null,
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated!")));
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
      appBar: AppBar(title: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: AppColors.primaryRed, elevation: 0),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryRed))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildImagePicker(),
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
                    const SizedBox(height: 20),

                    // --- Last Donation Date ---
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: AppColors.primaryRed, size: 20),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Last Donation Date", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text(_lastDonationDate == null ? "Not set" : DateFormat('dd MMM yyyy').format(_lastDonationDate!), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.edit, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    const Align(alignment: Alignment.centerLeft, child: Text("Update Location", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    const SizedBox(height: 10),
                    _buildDropdown("Division", Icons.map_outlined, _selectedDivision, LocationData.bdLocation.keys.toList(), (val) {
                      setState(() { _selectedDivision = val; _selectedDistrict = null; _selectedUpazila = null; });
                    }),
                    const SizedBox(height: 15),
                    if (_selectedDivision != null) _buildDropdown("District", Icons.location_city, _selectedDistrict, LocationData.bdLocation[_selectedDivision]!.keys.toList(), (val) {
                      setState(() { _selectedDistrict = val; _selectedUpazila = null; });
                    }),
                    const SizedBox(height: 15),
                    if (_selectedDistrict != null) _buildDropdown("Upazila", Icons.location_on_outlined, _selectedUpazila, LocationData.bdLocation[_selectedDivision]![_selectedDistrict]!, (val) => setState(() => _selectedUpazila = val)),
                    
                    const SizedBox(height: 40),
                    SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _updateProfile, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return Stack(
      children: [
        CircleAvatar(radius: 60, backgroundColor: Colors.grey[200], backgroundImage: _image != null ? FileImage(File(_image!.path)) : (widget.userData['profileImage'] != null ? NetworkImage(widget.userData['profileImage']) as ImageProvider : null), child: (_image == null && widget.userData['profileImage'] == null) ? const Icon(Icons.person, size: 60, color: Colors.grey) : null),
        Positioned(bottom: 0, right: 0, child: CircleAvatar(backgroundColor: AppColors.primaryRed, radius: 20, child: IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20), onPressed: _pickImage))),
      ],
    );
  }

  Widget _buildDropdown(String hint, IconData icon, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(decoration: _inputDecoration(hint, icon), value: value, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged);
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(controller: controller, keyboardType: keyboardType, decoration: _inputDecoration(hint, icon), validator: (val) => val!.isEmpty ? "Required" : null);
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: AppColors.primaryRed, size: 20), filled: true, fillColor: Colors.grey[50], enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primaryRed, width: 1)));
  }
}
