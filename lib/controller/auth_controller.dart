import 'package:e_leaningapp/export/export.dart';
import 'package:flutter/material.dart';

import '../utils/show_error_utils.dart';

class AuthController extends GetxController {
   var isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;

   void signUp(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      showSnackbar('Success', 'Account created successfully!',
          icon: Icons.check, backgroundColor: Colors.green);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      if (e is FirebaseAuthException) {
        String userFriendlyMessage;
        switch (e.code) {
          case "email-already-in-use":
            userFriendlyMessage = 'This email is already registered. Please use another email or log in.';
            break;
          case "weak-password":
            userFriendlyMessage = 'The password provided is too weak.';
            break;
          case "invalid-email":
            userFriendlyMessage = 'The email address is not valid.';
            break;
          case "operation-not-allowed":
            userFriendlyMessage = 'Signing up with email and password is not enabled.';
            break;
          case "user-disabled":
            userFriendlyMessage = 'This user has been disabled.';
            break;
          default:
            userFriendlyMessage = 'Failed to create account: ${e.message}';
            break;
        }
        showSnackbar('Error', userFriendlyMessage);
      } else {
        showSnackbar('Error', 'Failed to create account. Please try again.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  

   void login(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      showSnackbar('Success', 'Logged in successfully!',
          icon: Icons.check, backgroundColor: Colors.green);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      if (e is FirebaseAuthException) {
        String userFriendlyMessage;
        print(e.code);
        switch (e.code) {

          case "user-not-found":
            userFriendlyMessage = 'No user found for that email.';
            break;
          case "wrong-password":
            userFriendlyMessage = 'Wrong password provided.';
            break;
          case "invalid-email":
            userFriendlyMessage = 'The email address is not valid.';
            break;
          case "user-disabled":
            userFriendlyMessage = 'This user has been disabled.';
            break;
          case "too-many-requests":
            userFriendlyMessage = 'Too many requests. Try again later.';
            break;
          case "operation-not-allowed":
            userFriendlyMessage = 'Signing in with email and password is not enabled.';
            break;
          case "account-exists-with-different-credential":
            userFriendlyMessage = 'An account already exists with the same email but different sign-in credentials. Use a different method to sign in.';
            break;
          case "invalid-credential":
            userFriendlyMessage = 'The provided credentials are invalid.';
            break;
          default:
            userFriendlyMessage = 'Failed to log in: ${e.message}';
            break;
        }
        showSnackbar('Error', userFriendlyMessage);
      } else {
        showSnackbar('Error', 'Failed to log in. Please try again.');
      }
    } finally {
      isLoading.value = false;
    }
  }

}
