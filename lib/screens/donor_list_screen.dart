import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class DonorListScreen extends StatelessWidget {
  final String bloodGroup;
  final String? location;

  const DonorListScreen({super.key, required this.bloodGroup, this.location});

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('bloodGroup', isEqualTo: bloodGroup);

    if (location != null && location!.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('$bloodGroup Donors', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("No donors found in this area", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length, // .size এর বদলে .length করা হলো
            itemBuilder: (context, index) {
              var donor = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.secondaryRed,
                    child: Text(donor['bloodGroup'] ?? "", style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(donor['name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(donor['location'] ?? "No location", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text("Contact: ${donor['phone'] ?? "N/A"}", style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green, size: 30),
                    onPressed: () async {
                      final Uri launchUri = Uri(scheme: 'tel', path: donor['phone']);
                      if (await canLaunchUrl(launchUri)) {
                        await launchUrl(launchUri);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
