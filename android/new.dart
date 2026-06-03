static Future<void> _saveTokenToFirestore
(
String token) async {
User? user = FirebaseAuth.instance.currentUser;
if (user != null) {
// update এর বদলে set এবং SetOptions(merge: true) ব্যবহার করা হয়েছে
await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
'fcmToken': token,
'lastActive': FieldValue.serverTimestamp(),
}, SetOptions(merge: true)).catchError((e) => print("Error saving token: $e"));
}
}