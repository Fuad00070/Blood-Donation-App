import 'package:flutter/material.dart';
import '../models/donor_model.dart';

class DonorListScreen extends StatelessWidget {
  final String bloodGroup;

  const DonorListScreen({super.key, required this.bloodGroup});

  @override
  Widget build(BuildContext context) {
    // Mock data for donors
    final List<Donor> donors = [
      Donor(
        name: 'John Smith',
        bloodGroup: bloodGroup,
        location: 'Downtown Medical Center',
        phoneNumber: '+123456789',
        lastDonated: '3 months ago',
      ),
      Donor(
        name: 'Robert Wilson',
        bloodGroup: bloodGroup,
        location: 'City Hospital Area',
        phoneNumber: '+987654321',
        lastDonated: '6 months ago',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('$bloodGroup Donors', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: donors.length,
        itemBuilder: (context, index) {
          final donor = donors[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red[50],
                    child: Text(
                      donor.bloodGroup,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donor.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(donor.location, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Last Donated: ${donor.lastDonated}',
                          style: TextStyle(color: Colors.red[300], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
