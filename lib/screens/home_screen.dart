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
import 'my_requests_screen.dart';
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
            expandedHeight: 180.0,
            pinned: true,
            backgroundColor: AppColors.primaryRed,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'my_requests') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyRequestsScreen()));
                  }
                },
                icon: const Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'my_requests',
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: AppColors.primaryRed, size: 18),
                        SizedBox(width: 10),
                        Text('My Blood Requests'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryRed, Color(0xFFB71C1C)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 90, 20, 15),
                  child: Row(
                    children: [
                      // প্রোফাইল পিকচার বাম দিকে
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white24,
                          backgroundImage: profileImage != null ? NetworkImage(profileImage!) : null,
                          child: profileImage == null ? const Icon(Icons.person, color: Colors.white, size: 35) : null,
                        ),
                      ),
                      const SizedBox(width: 15), // পিকচার ও টেক্সটের মাঝে গ্যাপ
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello,", 
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName, 
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 22, 
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Ready to save a life today?", 
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
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
                  child: Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildActionCard(context, "Search", Icons.search_rounded, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchDonorScreen()))),
                      const SizedBox(width: 15),
                      _buildActionCard(context, "Request", Icons.emergency_rounded, AppColors.primaryRed, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestBloodScreen()))),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildActionCard(context, "Tips", Icons.lightbulb_rounded, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationTipsScreen()))),
                      const SizedBox(width: 15),
                      _buildActionCard(context, isDonor ? "Active" : "Be Donor", isDonor ? Icons.favorite_rounded : Icons.favorite_outline_rounded, isDonor ? Colors.green : Colors.pink, () => _toggleDonorStatus(isDonor)),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                  child: Text("Urgent Blood Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('blood_requests').orderBy('createdAt', descending: true).limit(10).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppColors.primaryRed)));
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
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              String display = count >= 1000 ? "${(count/1000).toStringAsFixed(1)}k+" : "$count";
              return _buildStatItem(display, "Donors", Icons.people_alt_rounded, Colors.blue);
            }
          ),
          const SizedBox(width: 10),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('blood_requests').where('status', isEqualTo: 'completed').snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return _buildStatItem("$count", "Lives Saved", Icons.volunteer_activism_rounded, Colors.orange);
            }
          ),
          const SizedBox(width: 10),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').where('isAvailable', isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return _buildStatItem("$count", "Active", Icons.flash_on_rounded, Colors.green);
            }
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08), 
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 9, color: color.withOpacity(0.7), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.1)),
            boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request) {
    bool isUrgent = request['isEmergency'] ?? false;
    bool isCompleted = request['status'] == 'completed';

    return Opacity(
      opacity: isCompleted ? 0.7 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCompleted ? Colors.green.shade100 : (isUrgent ? Colors.red.shade100 : Colors.grey.shade100)
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RequestDetailsScreen(request: request))),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? Colors.green.shade50 
                      : (isUrgent ? Colors.red : AppColors.secondaryRed), 
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Center(
                  child: Text(
                    request['bloodGroup'] ?? "?", 
                    style: TextStyle(
                      color: isCompleted 
                          ? Colors.green 
                          : (isUrgent ? Colors.white : AppColors.primaryRed), 
                      fontSize: 20, 
                      fontWeight: FontWeight.bold
                    )
                  )
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['hospitalName'] ?? "Hospital", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 15,
                        color: Colors.black87,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ), 
                      overflow: TextOverflow.ellipsis
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(child: Text(request['location'] ?? "Unknown", style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
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
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), 
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(6)), 
                      child: const Text("COLLECTED", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))
                    )
                  else if (isUrgent) 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), 
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                      child: const Text("URGENT", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
