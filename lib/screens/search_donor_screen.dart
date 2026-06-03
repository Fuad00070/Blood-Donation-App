import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../utils/location_data.dart';

class SearchDonorScreen extends StatefulWidget {
  const SearchDonorScreen({super.key});

  @override
  State<SearchDonorScreen> createState() => _SearchDonorScreenState();
}

class _SearchDonorScreenState extends State<SearchDonorScreen> {
  String _selectedGroup = 'A+';
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Find Donors", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                // Blood Group Selector
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _bloodGroups.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedGroup == _bloodGroups[index];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedGroup = _bloodGroups[index]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white24,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              _bloodGroups[index],
                              style: TextStyle(color: isSelected ? AppColors.primaryRed : Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // Location Dropdowns
                _buildDropdown("Division", _selectedDivision, LocationData.bdLocation.keys.toList(), (val) {
                  setState(() { _selectedDivision = val; _selectedDistrict = null; _selectedUpazila = null; });
                }),
                const SizedBox(height: 10),
                if (_selectedDivision != null)
                  _buildDropdown("District", _selectedDistrict, LocationData.bdLocation[_selectedDivision]!.keys.toList(), (val) {
                    setState(() { _selectedDistrict = val; _selectedUpazila = null; });
                  }),
                const SizedBox(height: 10),
                if (_selectedDistrict != null)
                  _buildDropdown("Upazila", _selectedUpazila, LocationData.bdLocation[_selectedDivision]![_selectedDistrict]!, (val) {
                    setState(() => _selectedUpazila = val);
                  }),
                
                if (_selectedDivision != null)
                  TextButton(
                    onPressed: () => setState(() { _selectedDivision = null; _selectedDistrict = null; _selectedUpazila = null; }),
                    child: const Text("Show All Areas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),

          // Donor List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getDonorStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
                
                // নিজের প্রোফাইল বাদ দেওয়া (Exclude current user)
                final List<DocumentSnapshot> donors = snapshot.data?.docs.where((doc) {
                  return doc.id != currentUserId; 
                }).toList() ?? [];

                if (donors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_rounded, size: 80, color: Colors.grey[200]),
                        const SizedBox(height: 10),
                        const Text("No other donors found", style: TextStyle(color: Colors.grey, fontSize: 16)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text("Hint: If your friend isn't showing, ask them to update their profile with location.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: donors.length,
                  itemBuilder: (context, index) {
                    var donor = donors[index].data() as Map<String, dynamic>;
                    return _buildDonorCard(donor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text("Select $hint", style: const TextStyle(fontSize: 14)),
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getDonorStream() {
    Query query = FirebaseFirestore.instance.collection('users')
        .where('bloodGroup', isEqualTo: _selectedGroup);

    // শুধু যদি লোকেশন সিলেক্ট করা থাকে তবেই ফিল্টার করবে
    if (_selectedUpazila != null) {
      query = query.where('upazila', isEqualTo: _selectedUpazila);
    } else if (_selectedDistrict != null) {
      query = query.where('district', isEqualTo: _selectedDistrict);
    } else if (_selectedDivision != null) {
      query = query.where('division', isEqualTo: _selectedDivision);
    }

    return query.snapshots();
  }

  Widget _buildDonorCard(Map<String, dynamic> donor) {
    String? photo = donor['profileImage'];
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.secondaryRed,
            backgroundImage: photo != null ? NetworkImage(photo) : null,
            child: photo == null ? const Icon(Icons.person, color: AppColors.primaryRed, size: 30) : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donor['name'] ?? "Unknown Donor", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        donor['upazila'] != null 
                          ? "${donor['upazila']}, ${donor['district']}" 
                          : (donor['location'] ?? "Unknown Location"), 
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.phone, color: Colors.white, size: 18)),
            onPressed: () async {
              final phone = donor['phone'];
              if (phone != null) {
                final Uri launchUri = Uri(scheme: 'tel', path: phone);
                if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
              }
            },
          ),
        ],
      ),
    );
  }
}
