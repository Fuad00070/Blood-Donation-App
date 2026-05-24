import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class RequestDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> request;

  const RequestDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Request Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.secondaryRed,
                child: Text(
                  request['bloodGroup'] ?? "?",
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            _infoTile(Icons.local_hospital, "Hospital", request['hospitalName']),
            _infoTile(Icons.location_on, "Location", request['location']),
            _infoTile(Icons.opacity, "Units Required", "${request['units']} Unit(s)"),
            _infoTile(Icons.phone, "Contact Number", request['contactNumber']),
            _infoTile(Icons.description, "Additional Details", request['details'] ?? "No extra details provided."),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri launchUri = Uri(scheme: 'tel', path: request['contactNumber']);
                  if (await canLaunchUrl(launchUri)) {
                    await launchUrl(launchUri);
                  }
                },
                icon: const Icon(Icons.call, color: Colors.white),
                label: const Text("Call Now", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryRed, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text(value ?? "N/A", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
