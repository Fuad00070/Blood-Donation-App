import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'donor_list_screen.dart';
import 'request_blood_screen.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, Rahim 👋", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("What would you like to do?", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildHomeOption(
            context,
            "Search Donor",
            "Find blood donors near you",
            Icons.bloodtype,
            () {},
          ),
          _buildHomeOption(
            context,
            "Become Donor",
            "Register yourself as donor",
            Icons.people_outline,
            () {},
          ),
          _buildHomeOption(
            context,
            "Emergency Request",
            "Request blood in emergency",
            Icons.warning_amber_rounded,
            () {},
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Donate Blood Save Life", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 5),
                      Text("Be a hero, Donate blood", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Image.network(
                  'https://cdn-icons-png.flaticon.com/512/822/822143.png',
                  height: 50,
                  width: 50,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildHomeOption(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Icon(icon, color: Colors.red, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
