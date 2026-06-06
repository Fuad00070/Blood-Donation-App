import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
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
                        const Text("No donors found", style: TextStyle(color: Colors.grey, fontSize: 16)),
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
    // এখানে .where('isAvailable', isEqualTo: true) সরিয়ে ফেলা হয়েছে 
    // যাতে ইনঅ্যাক্টিভ ইউজাররাও সার্চে আসে এবং আমরা তাদের স্ট্যাটাস দেখাতে পারি।
    Query query = FirebaseFirestore.instance.collection('users')
        .where('bloodGroup', isEqualTo: _selectedGroup);

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
    Timestamp? lastDonation = donor['lastDonationDate'];
    bool isAvailable = donor['isAvailable'] ?? false;
    
    // Eligibility Check
    bool isEligible = true;
    String nextDate = "";
    if (lastDonation != null) {
      DateTime nextEligibleDate = lastDonation.toDate().add(const Duration(days: 120));
      isEligible = DateTime.now().isAfter(nextEligibleDate);
      nextDate = DateFormat('dd MMM yyyy').format(nextEligibleDate);
    }

    // চূড়ান্তভাবে ডোনার এভেইলেবল কি না (অ্যাক্টিভ বাটন + ৪ মাস সময়)
    bool canDonate = isAvailable && isEligible;

    return Opacity(
      opacity: canDonate ? 1.0 : 0.6, // এভেইলেবল না হলে ঝাপসা দেখাবে
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          border: canDonate ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: canDonate ? AppColors.secondaryRed : Colors.grey[200],
                  backgroundImage: photo != null ? NetworkImage(photo) : null,
                  child: photo == null ? Icon(Icons.person, color: canDonate ? AppColors.primaryRed : Colors.grey, size: 30) : null,
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
                  icon: CircleAvatar(
                    backgroundColor: canDonate ? Colors.green : Colors.grey[300], 
                    child: Icon(Icons.phone, color: canDonate ? Colors.white : Colors.grey, size: 18)
                  ),
                  onPressed: canDonate ? () async {
                    final phone = donor['phone'];
                    if (phone != null) {
                      final Uri launchUri = Uri(scheme: 'tel', path: phone);
                      if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
                    }
                  } : null,
                ),
              ],
            ),
            // স্ট্যাটাস মেসেজ
            if (!canDonate) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: !isAvailable ? Colors.grey[100] : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      !isAvailable ? Icons.do_not_disturb_on : Icons.info_outline, 
                      size: 14, 
                      color: !isAvailable ? Colors.grey : Colors.orange
                    ),
                    const SizedBox(width: 8),
                    Text(
                      !isAvailable ? "Not Ready to Donate!" : "Next Eligible: $nextDate",
                      style: TextStyle(
                        color: !isAvailable ? Colors.grey : Colors.orange, 
                        fontSize: 12, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
