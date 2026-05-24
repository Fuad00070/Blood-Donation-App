// ... অন্য ইমপোর্টগুলো
static void _showNotification
(
RemoteMessage message) async {
const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
'blood_requests_channel',
'Blood Requests',
importance: Importance.max,
priority: Priority.high,
);
const NotificationDetails platformChannelSpecifics = NotificationDetails(
android: androidPlatformChannelSpecifics,
);

await _localNotificationsPlugin.show(
0,
message.notification?.title ?? "No Title",
message.notification?.body ?? "No Body",
platformChannelSpecifics,
);
}