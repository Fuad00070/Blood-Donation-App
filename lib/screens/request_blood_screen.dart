import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../utils/location_data.dart';

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
  final _detailsController = TextEditingController();
  
  String? _selectedGroup;
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  bool _isLoading = false;
  bool _isEmergency = false;
  
  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  Future<void> _postRequest() async {
    if (!_formKey.currentState!.validate() || _selectedGroup == null || _selectedUpazila == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields including full location")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      String fullLocation = "$_selectedUpazila, $_selectedDistrict";
      
      await FirebaseFirestore.instance.collection('blood_requests').add({
        'hospitalName': _hospitalController.text.trim(),
        'bloodGroup': _selectedGroup,
        'contactNumber': _contactController.text.trim(),
        'units': _unitsController.text.trim(),
        'location': fullLocation,
        'division': _selectedDivision,
        'district': _selectedDistrict,
        'upazila': _selectedUpazila,
        'details': _detailsController.text.trim(),
        'isEmergency': _isEmergency,
        'postedBy': user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Posted Successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Emergency Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
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
              _buildEmergencyToggle(),
              const SizedBox(height: 25),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Blood Group Required", Icons.opacity),
                items: bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => _selectedGroup = val),
              ),
              const SizedBox(height: 15),
              _buildField(_hospitalController, "Hospital Name", Icons.local_hospital),
              const SizedBox(height: 15),

              // Smart Location Dropdowns
              _buildLocationDropdowns(),

              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildField(_unitsController, "Units", Icons.bloodtype, keyboardType: TextInputType.number)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildField(_contactController, "Phone", Icons.phone, keyboardType: TextInputType.phone)),
                ],
              ),
              const SizedBox(height: 15),
              _buildField(_detailsController, "Additional Notes", Icons.description, maxLines: 2),
              
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyToggle() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _isEmergency ? Colors.red[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _isEmergency ? Colors.red : Colors.transparent),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: _isEmergency ? Colors.red : Colors.grey),
          const SizedBox(width: 15),
          const Expanded(child: Text("Is this an Emergency?", style: TextStyle(fontWeight: FontWeight.bold))),
          Switch(value: _isEmergency, activeColor: Colors.red, onChanged: (val) => setState(() => _isEmergency = val)),
        ],
      ),
    );
  }

  Widget _buildLocationDropdowns() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: _inputDecoration("Select Division", Icons.map_outlined),
          value: _selectedDivision,
          items: LocationData.bdLocation.keys.map((div) => DropdownMenuItem(value: div, child: Text(div))).toList(),
          onChanged: (val) => setState(() { _selectedDivision = val; _selectedDistrict = null; _selectedUpazila = null; }),
        ),
        if (_selectedDivision != null) ...[
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            decoration: _inputDecoration("Select District", Icons.location_city),
            value: _selectedDistrict,
            items: LocationData.bdLocation[_selectedDivision]!.keys.map((dis) => DropdownMenuItem(value: dis, child: Text(dis))).toList(),
            onChanged: (val) => setState(() { _selectedDistrict = val; _selectedUpazila = null; }),
          ),
        ],
        if (_selectedDistrict != null) ...[
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            decoration: _inputDecoration("Select Upazila", Icons.location_on_outlined),
            value: _selectedUpazila,
            items: LocationData.bdLocation[_selectedDivision]![_selectedDistrict]!.map((upa) => DropdownMenuItem(value: upa, child: Text(upa))).toList(),
            onChanged: (val) => setState(() => _selectedUpazila = val),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _postRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isEmergency ? Colors.red[900] : AppColors.primaryRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(_isEmergency ? "POST EMERGENCY NOW" : "Post Request", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint, icon),
      validator: (val) => val!.isEmpty ? "Required" : null,
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primaryRed, size: 20),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    );
  }
}
