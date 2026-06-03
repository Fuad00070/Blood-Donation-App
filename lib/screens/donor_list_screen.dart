import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class DonorListScreen extends StatelessWidget {
  final String bloodGroup;
  final String? division;
  final String? district;
  final String? upazila;

  const DonorListScreen({
    super.key, 
    required this.bloodGroup, 
    this.division, 
    this.district, 
    this.upazila
  });

  @override
  Widget build(BuildContext context) {
    // ফায়ারবেস কুয়েরি শুরু
    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('bloodGroup', isEqualTo: bloodGroup);

    // স্মার্ট ফিল্টারিং লজিক:
    // ১. যদি উপজেলা সিলেক্ট করা থাকে, তবে শুধু ওই উপজেলার ডোনার দেখাবে।
    // ২. যদি উপজেলা না থাকে কিন্তু জেলা থাকে, তবে ওই জেলার সব ডোনার দেখাবে।
    // ৩. যদি শুধু বিভাগ থাকে, তবে ওই বিভাগের সব ডোনার দেখাবে।
    
    if (upazila != null && upazila!.isNotEmpty) {
      query = query.where('upazila', isEqualTo: upazila);
    } else if (district != null && district!.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
    } else if (division != null && division!.isNotEmpty) {
      query = query.where('division', isEqualTo: division);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('$bloodGroup Donors', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 15),
                  Text(
                    "No $bloodGroup donors found in ${upazila ?? district ?? division ?? 'this area'}",
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var donor = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String? photo = donor['profileImage'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.secondaryRed,
                    backgroundImage: photo != null ? NetworkImage(photo) : null,
                    child: photo == null ? const Icon(Icons.person, color: AppColors.primaryRed) : null,
                  ),
                  title: Text(donor['name'] ?? "Donor", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(donor['location'] ?? "${donor['upazila']}, ${donor['district']}", style: const TextStyle(fontSize: 12)),
                  trailing: IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.phone, color: Colors.white, size: 18),
                    ),
                    onPressed: () async {
                      final phone = donor['phone'];
                      if (phone != null) {
                        final Uri launchUri = Uri(scheme: 'tel', path: phone);
                        if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
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
