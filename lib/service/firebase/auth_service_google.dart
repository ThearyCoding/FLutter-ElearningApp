import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../utils/show_error_utils.dart';

class AuthServiceGoogle {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Please wait...');

      // Sign out the current user if any
      await _googleSignIn.signOut();

      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      // User canceled the sign-in process
      if (googleSignInAccount == null) {
        return null;
      }

      // Obtain the GoogleSignInAuthentication object
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);

      return authResult.user;
    } catch (error) {
      EasyLoading.dismiss();
      if (error is FirebaseAuthException) {
        showFriendlyErrorSnackbar(error.code, error.message);
      } else {
        debugPrint("Error signing in with Google: $error");
        showFriendlyErrorSnackbar(
            'Error', 'An error occurred while signing in with Google.');
      }

      return null;
    } finally {
      EasyLoading.dismiss();
    }
  }

  void showFriendlyErrorSnackbar(String code, String? message) {
    String userFriendlyMessage;

    switch (code) {
      case 'account-exists-with-different-credential':
        userFriendlyMessage =
            'An account already exists with a different credential.';
        break;
      case 'invalid-email':
        userFriendlyMessage = 'The email address is not valid.';
        break;
      case 'user-not-found':
        userFriendlyMessage = 'No user found with this email.';
        break;
      case 'wrong-password':
        userFriendlyMessage = 'The password is incorrect.';
        break;
      case 'user-disabled':
        userFriendlyMessage = 'The user has been disabled.';
        break;
      case 'too-many-requests':
        userFriendlyMessage = 'Too many requests. Please try again later.';
        break;
      case 'operation-not-allowed':
        userFriendlyMessage = 'This operation is not allowed.';
        break;
      default:
        userFriendlyMessage =
            'An unexpected error occurred: ${message ?? 'Unknown error'}';
        break;
    }
    showSnackbar(
      'Error',
      userFriendlyMessage,
    );
  }

  bool isSignedInWithGoogle(User user) {
    for (var userInfo in user.providerData) {
      if (userInfo.providerId == 'google.com') {
        return true;
      }
    }
    return false;
  }
}
