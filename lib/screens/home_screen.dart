import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_drawer.dart';
import 'request_blood_screen.dart';
import 'search_donor_screen.dart';
import 'request_details_screen.dart';
import 'donation_tips_screen.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String userName = "Donor";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        setState(() {
          userName = userData['name'] ?? "Donor";
        });
      }
    }
  }

  Future<void> _becomeDonor() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'isAvailable': true,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your profile is now marked as an available donor!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, $userName 👋", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Hope you are doing well", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHomeOption(context, "Search Donor", "Find blood donors near you", Icons.bloodtype, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchDonorScreen()));
            }),
            _buildHomeOption(context, "Become Donor", "Register yourself as donor", Icons.people_outline, () {
              _becomeDonor();
            }),
            _buildHomeOption(context, "Emergency Request", "Request blood in emergency", Icons.warning_amber_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestBloodScreen()));
            }),
            
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Text("Urgent Blood Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('blood_requests').orderBy('createdAt', descending: true).limit(5).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No urgent requests at the moment.")));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var request = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.secondaryRed,
                          child: Text(request['bloodGroup'] ?? "?", style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(request['hospitalName'] ?? "Hospital", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${request['units']} Unit(s) • ${request['location']}"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => RequestDetailsScreen(request: request)));
                        },
                      ),
                    );
                  },
                );
              },
            ),
            
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Text("Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildHomeOption(context, "Donation Tips", "Learn about blood donation", Icons.lightbulb_outline, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationTipsScreen()));
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeOption(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Icon(icon, color: AppColors.primaryRed, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
