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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blood_requests')
            .where('postedBy', isEqualTo: user?.uid)
            .orderBy('createdAt', descending: true)
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
                  Icon(Icons.history_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("You haven't posted any requests yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var requestDoc = snapshot.data!.docs[index];
              var request = requestDoc.data() as Map<String, dynamic>;
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondaryRed,
                    child: Text(request['bloodGroup'] ?? "?", style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(request['hospitalName'] ?? "Hospital", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Units: ${request['units']} • Status: ${request['status'] ?? 'Pending'}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(context, requestDoc.id),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RequestDetailsScreen(request: request)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Request?"),
        content: const Text("Are you sure you want to remove this blood request?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('blood_requests').doc(docId).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
