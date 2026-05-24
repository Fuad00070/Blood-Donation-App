import 'package:flutter/material.dart';
import '../utils/constants.dart';

class DonationTipsScreen extends StatelessWidget {
  const DonationTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Donation Tips", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTipCard(
            "Before Donation",
            "• Get a good night's sleep.\n• Eat a healthy meal.\n• Drink plenty of water.\n• Avoid fatty foods.",
            Icons.restaurant,
          ),
          _buildTipCard(
            "During Donation",
            "• Wear comfortable clothing.\n• Relax and breathe normally.\n• Tell the staff if you feel dizzy.",
            Icons.volunteer_activism,
          ),
          _buildTipCard(
            "After Donation",
            "• Drink extra fluids.\n• Avoid strenuous physical activity.\n• Keep the bandage on for a few hours.\n• Eat iron-rich foods.",
            Icons.bed,
          ),
          _buildTipCard(
            "Eligibility",
            "• Weight: At least 50 kg.\n• Age: 18-65 years.\n• Hemoglobin: Minimum 12.5 g/dL.\n• Pulse: Normal (60-100 bpm).",
            Icons.fact_check,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String content, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryRed, size: 28),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              content,
              style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
