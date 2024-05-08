import 'dart:io';
import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/user_model.dart';

class UserRepository {
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String email,
    required UserModel user,
    File? image,
  }) async {
    if (image != null) {
      dev.log('Uploading user image', name: 'Profile');
      await _storage.ref('profile_pics/$email').putFile(
            image,
          );
      dev.log('Image uploaded', name: 'Profile');
      final url = await _storage.ref('profile_pics/$email').getDownloadURL();
      user = user.copyWith(profilePicUrl: url);
    }

    await _firestore.collection('users').doc(email).set(
          user.toMap(),
        );
  }

  Future<void> editUserProfile({
    required String email,
    required UserModel user,
    File? image,
    required bool removeImage,
  }) async {
    dev.log('Updating user: $user', name: 'Profile');
    if (image != null && !removeImage) {
      dev.log('Uploading user image', name: 'Profile');
      await _storage.ref('profile_pics/$email').putFile(
        image,
      );
      dev.log('Image uploaded', name: 'Profile');
      final url = await _storage.ref('profile_pics/$email').getDownloadURL();
      user = user.copyWith(profilePicUrl: url);
    }
    if (removeImage) {
      dev.log('Removing profile image', name: 'Profile');
      user = user.copyWith(profilePicUrl: null);
    }

    await _firestore.collection('users').doc(email).update(
      user.toMap(),
    );
  }

  Stream<UserModel?> getUserProfile(String email) {
    return _firestore.collection('users').doc(email).snapshots().map(
      (snapshot) {
        final data = snapshot.data();
        if (data == null) return null;

        return UserModel.fromMap(data);
      },
    );
  }
}
