import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/app_drawer.dart';
import 'request_blood_screen.dart';
import 'search_donor_screen.dart';
import 'donor_list_screen.dart';
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
  String? profileImage;
  bool isDonor = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).snapshots().listen((snapshot) {
        if (snapshot.exists && mounted) {
          setState(() {
            userName = snapshot.data()?['name'] ?? "Donor";
            profileImage = snapshot.data()?['profileImage'];
            isDonor = snapshot.data()?['isAvailable'] ?? false;
          });
        }
      });
    }
  }

  Future<void> _toggleDonorStatus(bool currentStatus) async {
    User? user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore.collection('users').doc(user.uid).update({'isAvailable': !currentStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(!currentStatus ? "Active Donor Mode On!" : "Donor Mode Off."),
          backgroundColor: !currentStatus ? Colors.green : Colors.grey,
        ));
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // সময়ের পার্থক্য বের করার জন্য ছোট একটি ফাংশন
  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return "Just now";
    DateTime postDate = timestamp.toDate();
    Duration diff = DateTime.now().difference(postDate);

    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "Just now";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            pinned: true,
            backgroundColor: AppColors.primaryRed,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primaryRed, Color(0xFFC62828)]),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(60, 50, 20, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Hello, $userName 👋", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text("Ready to save a life today?", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white24,
                        backgroundImage: profileImage != null ? NetworkImage(profileImage!) : null,
                        child: profileImage == null ? const Icon(Icons.person, color: Colors.white) : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsSection(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildActionCard(context, "Search", Icons.search, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchDonorScreen()))),
                      const SizedBox(width: 15),
                      _buildActionCard(context, "Request", Icons.emergency_share, AppColors.primaryRed, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestBloodScreen()))),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildActionCard(context, "Tips", Icons.lightbulb_outline, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationTipsScreen()))),
                      const SizedBox(width: 15),
                      _buildActionCard(context, isDonor ? "Active" : "Be Donor", isDonor ? Icons.favorite : Icons.favorite_border, isDonor ? Colors.green : Colors.pink, () => _toggleDonorStatus(isDonor)),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                  child: Text("Urgent Blood Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('blood_requests').orderBy('createdAt', descending: true).limit(10).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var request = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return _buildRequestCard(context, request);
                  },
                  childCount: snapshot.data!.docs.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatItem("1.5k+", "Donors", Icons.people, Colors.blue),
          const SizedBox(width: 15),
          _buildStatItem("900+", "Lives Saved", Icons.volunteer_activism, Colors.orange),
          const SizedBox(width: 15),
          _buildStatItem("24/7", "Active", Icons.flash_on, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 9, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request) {
    bool isUrgent = request['isEmergency'] ?? false;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isUrgent ? Border.all(color: Colors.red.shade100) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RequestDetailsScreen(request: request))),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(color: isUrgent ? Colors.red : AppColors.secondaryRed, borderRadius: BorderRadius.circular(15)),
              child: Center(child: Text(request['bloodGroup'] ?? "?", style: TextStyle(color: isUrgent ? Colors.white : AppColors.primaryRed, fontSize: 20, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request['hospitalName'] ?? "Hospital", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(request['location'] ?? "Unknown", style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_getTimeAgo(request['createdAt']), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 5),
                if (isUrgent) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)), child: const Text("URGENT", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
