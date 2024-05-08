import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<bool> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      dev.log('Error while signup: $e', name: 'Auth');
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      dev.log('Successfully logged in', name: 'Auth');
      return true;
    } catch (e) {
      dev.log('Error: $e', name: 'Auth');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await _firebaseAuth.signOut();
      dev.log('Sign out successful', name: 'Auth');
      return true;
    }catch(e) {
      dev.log('Error: $e', name: 'Auth');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  String getEmail() {
    return _firebaseAuth.currentUser!.email!;
  }
}