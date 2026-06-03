import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

final cloudinary = CloudinaryPublic(
  'dlwhkzh5w',
  'blood_app_preset',
  cache: false,
);

class ProfileLogic {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> updateFullProfile({
    required String userId,
    required String name,
    required String phone,
    String? location,
    String? bloodGroup,
    XFile? imageFile,
  }) async {
    try {
      String? imageUrl;

      if (imageFile != null) {
        // ক্লাউডিনারি আপলোড - টাইমআউটসহ
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(imageFile.path, folder: 'profile_pics'),
        ).timeout(const Duration(seconds: 30));
        imageUrl = response.secureUrl;
      }

      Map<String, dynamic> updateData = {
        'name': name,
        'phone': phone,
        if (location != null) 'location': location,
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (imageUrl != null) {
        updateData['profileImage'] = imageUrl;
      }

      // ফায়ারস্টোর আপডেট
      await _firestore.collection('users').doc(userId).update(updateData).timeout(const Duration(seconds: 15));
      
      print("Profile successfully saved in Backend!");
    } catch (e) {
      print("Error in ProfileLogic: $e");
      rethrow;
    }
  }
}
