import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // গ্লোবাল নেভিগেটর কী যাতে যেকোনো জায়গা থেকে স্ক্রিন পরিবর্তন করা যায়
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    await _firebaseMessaging.requestPermission();

    // অ্যাপ চালু হওয়ার সময় টোকেন আপডেট
    updateToken();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // এখানে ক্লিক করলে কী হবে তা নিয়ন্ত্রণ করা যায়
      },
    );

    // ফোরগ্রাউন্ড নোটিফিকেশন লিসেনার
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // ব্যাকগ্রাউন্ড থেকে নোটিফিকেশন ক্লিক করলে অ্যাপ ওপেন হওয়া
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageNavigation(message);
    });

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _saveTokenToFirestore(newToken);
    });
  }

  static void _handleMessageNavigation(RemoteMessage message) {
    // এখানে আপনি চাইলে নির্দিষ্ট ডাটা অনুযায়ী নেভিগেট করতে পারেন
    print("Navigating to details via Notification click");
  }

  static Future<void> updateToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveTokenToFirestore(token);
    }
  }

  static Future<void> _saveTokenToFirestore(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': token,
      }).catchError((e) => print("Error saving token: $e"));
    }
  }

  static void _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'blood_requests_channel',
      'Blood Requests',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _localNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? "Emergency Blood Request",
      message.notification?.body ?? "Someone needs blood near you!",
      platformChannelSpecifics,
    );
  }
}
