import 'package:e_leaningapp/utils/show_error_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/material.dart';

class AuthServiceFacebook {

  Future<UserCredential?> loginWithFacebook(BuildContext context) async {
    try {
      EasyLoading.show(
          status: 'Please wait...', maskType: EasyLoadingMaskType.clear);
      // Trigger Facebook sign in
      final LoginResult result = await FacebookAuth.instance.login();

      // ignore: unnecessary_null_comparison
      if (result == null) {
        // User canceled the sign-in process
        EasyLoading.dismiss();
        return null;
      }
      // Check if Facebook sign in was successful
      if (result.status == LoginStatus.success) {
        // Retrieve Facebook access token
        final AccessToken accessToken = result.accessToken!;

        // Convert Facebook access token to AuthCredential
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.token);

        // Sign in with Facebook credential
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        EasyLoading.dismiss();
        // Return the signed-in user credential
        return userCredential;
      } else {
        // Facebook sign in failed
        debugPrint("Facebook sign in failed: ${result.status}");
        return null;
      }
    } on FirebaseAuthException catch (error) {
      debugPrint(
          "Error during Facebook login: ${error.code} - ${error.message}");

      if (error.code == 'account-exists-with-different-credential') {
        showSnackbar('Error',
            'An account already exists with the same email address but different sign-in credentials.');
      }
    } catch (error) {
      debugPrint("Error during Facebook login: $error");
      return null;
    } finally {
      EasyLoading.dismiss();
    }

    return null;
  }


  bool isSignedInWithFacebook(User user) {
    for (var userInfo in user.providerData) {
      if (userInfo.providerId == 'facebook.com') {
        return true;
      }
    }
    return false;
  }
}
