import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class DonationHistoryScreen extends StatelessWidget {
  const DonationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Donation History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .where('donorId', isEqualTo: user?.uid)
            .orderBy('date', descending: true)
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
                  const Text("No donation records found.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var donation = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              DateTime date = (donation['date'] as Timestamp).toDate();
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.secondaryRed,
                    child: Icon(Icons.volunteer_activism, color: AppColors.primaryRed),
                  ),
                  title: Text(donation['hospitalName'] ?? "Hospital", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Date: ${DateFormat('dd MMM yyyy').format(date)}"),
                  trailing: const Text("Success", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addDonationRecord(context),
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _addDonationRecord(BuildContext context) {
    // এখানে একটি ছোট ফর্ম বা ডায়ালগ বক্স দেখানো যায় ডাটা ইনপুট দেওয়ার জন্য
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Record"),
        content: const Text("Feature to add manual donation records coming soon!"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }
}
