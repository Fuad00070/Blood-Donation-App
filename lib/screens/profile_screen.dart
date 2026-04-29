import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.red,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('John Doe',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Blood Group: A+',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () {}, child: const Text('Edit Profile')),
          ],
        ),
      ),
    );
  }
}
