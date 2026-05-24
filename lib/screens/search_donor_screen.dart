import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import 'donor_list_screen.dart';

class SearchDonorScreen extends StatefulWidget {
  const SearchDonorScreen({super.key});

  @override
  State<SearchDonorScreen> createState() => _SearchDonorScreenState();
}

class _SearchDonorScreenState extends State<SearchDonorScreen> {
  String _selectedGroup = 'A+';
  final TextEditingController _locationController = TextEditingController();
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Search Donor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Blood Group", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: _bloodGroups.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedGroup == _bloodGroups[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedGroup = _bloodGroups[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryRed : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        _bloodGroups[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text("Location (Optional)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: "e.g. Dhaka",
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonorListScreen(
                        bloodGroup: _selectedGroup,
                        location: _locationController.text.trim(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Search Donors", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
