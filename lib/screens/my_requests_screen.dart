import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import 'request_details_screen.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Blood Requests", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blood_requests')
            .where('postedBy', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add, size: 80, color: Colors.grey[200]),
                  const SizedBox(height: 10),
                  const Text("You haven't posted any requests yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // ইন-মেমোরি সর্টিং (যদি ইনডেক্স এরর এড়াতে চান)
          var docs = snapshot.data!.docs;
          docs.sort((a, b) => (b['createdAt'] as Timestamp).compareTo(a['createdAt'] as Timestamp));

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var request = doc.data() as Map<String, dynamic>;
              bool isCompleted = request['status'] == 'completed';

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isCompleted ? Colors.green.shade100 : Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: isCompleted ? Colors.green[50] : AppColors.secondaryRed,
                    child: Text(request['bloodGroup'] ?? "?", style: TextStyle(color: isCompleted ? Colors.green : AppColors.primaryRed, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(
                    request['hospitalName'] ?? "Hospital", 
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "Status: ${isCompleted ? 'Collected' : 'Pending'}", 
                    style: TextStyle(color: isCompleted ? Colors.green : Colors.orange, fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCompleted)
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => _markAsCollected(context, doc.id),
                          tooltip: 'Mark as Found',
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _confirmDelete(context, doc.id),
                        tooltip: 'Delete Post',
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RequestDetailsScreen(request: request))),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _markAsCollected(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Found Blood?"),
        content: const Text("This will mark your request as completed."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('blood_requests').doc(docId).update({'status': 'completed'});
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Yes, Found!", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Request?"),
        content: const Text("Are you sure you want to remove this post forever?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('blood_requests').doc(docId).delete();
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
