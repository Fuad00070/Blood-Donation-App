import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import 'auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // রক্তদানের যোগ্যতা চেক করার ফাংশন
  Map<String, dynamic> _checkEligibility(Timestamp? lastDonation) {
    if (lastDonation == null) return {'isEligible': true, 'message': 'Ready to Donate!'};
    
    DateTime lastDate = lastDonation.toDate();
    DateTime nextEligibleDate = lastDate.add(const Duration(days: 120)); // ৪ মাস পর
    bool isEligible = DateTime.now().isAfter(nextEligibleDate);
    
    if (isEligible) {
      return {'isEligible': true, 'message': 'Ready to Donate!'};
    } else {
      String dateStr = DateFormat('dd MMM yyyy').format(nextEligibleDate);
      return {'isEligible': false, 'message': 'Next Eligible: $dateStr'};
    }
  }

  @override
  Widget build(BuildContext context) {
    var eligibility = _checkEligibility(userData?['lastDonationDate']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _auth.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              }
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryRed))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          backgroundImage: (userData?['profileImage'] != null) ? NetworkImage(userData!['profileImage']) : null,
                          child: (userData?['profileImage'] == null) ? const Icon(Icons.person, size: 60, color: AppColors.primaryRed) : null,
                        ),
                        const SizedBox(height: 15),
                        Text(userData?['name'] ?? "User Name", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        
                        // Eligibility Badge
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                            color: eligibility['isEligible'] ? Colors.green : Colors.yellow[700],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            eligibility['message'],
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildProfileItem(Icons.bloodtype, "Blood Group", userData?['bloodGroup'] ?? "N/A"),
                  _buildProfileItem(Icons.location_on, "Location", "${userData?['upazila'] ?? ''}, ${userData?['district'] ?? ''}"),
                  _buildProfileItem(Icons.phone, "Phone Number", userData?['phone'] ?? "N/A"),
                  _buildProfileItem(Icons.calendar_today, "Last Donation", 
                    userData?['lastDonationDate'] != null 
                      ? DateFormat('dd MMM yyyy').format((userData!['lastDonationDate'] as Timestamp).toDate()) 
                      : "Not set"),
                  
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () async {
                          if (userData != null) {
                            bool? updated = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(userData: userData!)));
                            if (updated == true) _fetchProfile();
                          }
                        },
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryRed), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text("Edit Profile", style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryRed, size: 20),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
