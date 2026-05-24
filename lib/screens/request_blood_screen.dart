import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class RequestBloodScreen extends StatefulWidget {
  const RequestBloodScreen({super.key});

  @override
  State<RequestBloodScreen> createState() => _RequestBloodScreenState();
}

class _RequestBloodScreenState extends State<RequestBloodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _contactController = TextEditingController();
  final _unitsController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailsController = TextEditingController();
  
  String? _selectedGroup;
  bool _isLoading = false;
  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  Future<void> _postRequest() async {
    if (!_formKey.currentState!.validate() || _selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // Firestore-এ 'blood_requests' কালেকশনে ডেটা সেভ করা
      await FirebaseFirestore.instance.collection('blood_requests').add({
        'hospitalName': _hospitalController.text.trim(),
        'bloodGroup': _selectedGroup,
        'contactNumber': _contactController.text.trim(),
        'units': _unitsController.text.trim(),
        'location': _locationController.text.trim(),
        'details': _detailsController.text.trim(),
        'postedBy': user?.uid,
        'postedByName': user?.displayName ?? "Anonymous",
        'createdAt': DateTime.now(),
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blood Request Posted Successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post request: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post Blood Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter Hospital & Blood Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Select Blood Group", Icons.opacity),
                items: bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => _selectedGroup = val),
                validator: (val) => val == null ? "Select a group" : null,
              ),
              const SizedBox(height: 15),
              
              _buildFormFields(_hospitalController, "Hospital Name", Icons.local_hospital),
              const SizedBox(height: 15),
              
              _buildFormFields(_locationController, "Location (Area/City)", Icons.location_on),
              const SizedBox(height: 15),
              
              Row(
                children: [
                  Expanded(child: _buildFormFields(_unitsController, "Units/Bags", Icons.bloodtype, keyboardType: TextInputType.number)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildFormFields(_contactController, "Contact", Icons.phone, keyboardType: TextInputType.phone)),
                ],
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _detailsController,
                maxLines: 3,
                decoration: _inputDecoration("Additional Details", Icons.description),
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _postRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Post Request', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
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
