import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  User? get currentUser => _auth.currentUser;

  String get userName {
    final name = currentUser?.displayName?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = currentUser?.email;

    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'User';
  }

  String get userEmail => currentUser?.email ?? '';

  String? get photoUrl => currentUser?.photoURL;

  Future<void> updateName(String name) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw Exception('Name cannot be empty.');
    }

    await user.updateDisplayName(trimmedName);
    await user.reload();
  }

  Future<String?> pickAndUploadProfilePhoto() async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Please sign in first.');
    }

    final XFile? pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1000,
    );

    if (pickedImage == null) {
      return null;
    }

    final imageFile = File(pickedImage.path);

    final storageRef = _storage
        .ref()
        .child('profile_photos')
        .child('${user.uid}.jpg');

    await storageRef.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final downloadUrl = await storageRef.getDownloadURL();

    await user.updatePhotoURL(downloadUrl);
    await user.reload();

    return downloadUrl;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
