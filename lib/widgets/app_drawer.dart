import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth/login_screen.dart';
import '../screens/my_requests_screen.dart';
import '../screens/donation_history_screen.dart';
import '../screens/donation_tips_screen.dart';
import '../utils/constants.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primaryRed),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bloodtype, color: Colors.white, size: 60),
                SizedBox(height: 10),
                Text('Blood Donation App',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _drawerItem(Icons.home_outlined, 'Home', () => Navigator.pop(context)),
          _drawerItem(Icons.favorite_border, 'My Blood Requests', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyRequestsScreen()));
          }),
          _drawerItem(Icons.history, 'Donation History', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationHistoryScreen()));
          }),
          _drawerItem(Icons.lightbulb_outline, 'Donation Tips', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationTipsScreen()));
          }),
          _drawerItem(Icons.info_outline, 'About Us', () {
            showAboutDialog(
              context: context,
              applicationName: "Blood Link",
              applicationVersion: "1.0.0",
              applicationIcon: const Icon(Icons.bloodtype, color: Colors.red),
              children: [const Text("This app connects blood donors with people in need efficiently and quickly.")],
            );
          }),
          const Divider(),
          _drawerItem(Icons.logout, 'Logout', () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          }, color: Colors.red),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700]),
      title: Text(title, style: TextStyle(color: color ?? Colors.black87, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
