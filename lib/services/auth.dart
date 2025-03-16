import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/views/widget/show_custom_snackbar.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // sign in with email & password
  Future<User?> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      // ignore: use_build_context_synchronously
      showCustomSnackBar(
          context, 'Invalid email or password. Please try again!');
      print('Some error occurred');
    }
    return null;
  }

  // register with email & password
  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      print('Some error occurred');
    }
    return null;
  }

  // sign in with google account

  // register with google account
}
