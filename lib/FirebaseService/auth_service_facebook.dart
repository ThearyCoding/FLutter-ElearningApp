import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthServiceFacebook {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    try {
      return _auth.currentUser;
    } catch (error) {
      print("Error getting current user: $error");
      return null;
    }
  }

  Future<bool> isInformationComplete(User user) async {
    // Assume you have a collection named 'users' in Firestore
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');

    try {
      // Get the document for the current user
      DocumentSnapshot snapshot = await users.doc(user.uid).get();

      // Check if the document exists and if all required fields are present
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        if (userData.containsKey('firstName') &&
            userData.containsKey('lastName')) {
          // Check if all required fields are present
          return true;
        } else {
          // Information is not complete
          return false;
        }
      } else {
        // Document does not exist, information is not complete
        return false;
      }
    } catch (error) {
      // Error occurred while checking information completeness
      print('Error checking information completeness: $error');
      return false;
    }
  }

  bool isSignedInWithFacebook(User user) {
    for (var userInfo in user.providerData) {
      if (userInfo.providerId == 'facebook.com') {
        return true;
      }
    }
    return false;
  }

  Future<UserCredential?> loginWithFacebook(BuildContext context) async {
    try {
      // Trigger Facebook sign in
      final LoginResult result = await FacebookAuth.instance.login();

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

        // Return the signed-in user credential
        return userCredential;
      } else {
        // Facebook sign in failed
        print("Facebook sign in failed: ${result.status}");
        return null;
      }
    } on FirebaseAuthException catch (error) {
      // Inside your authentication handling code
      print("Error during Facebook login: ${error.code} - ${error.message}");

      if (error.code == 'account-exists-with-different-credential') {
        // Handle account linking
        _handleAccountLinking(error);
      } else {
        // Other FirebaseAuthExceptions, show error message to the user
        _showErrorMessage(context,
            'An account already exists with the same email address but different sign-in credentials.');
      }
    } catch (error) {
      // Handle other errors
      print("Error during Facebook login: $error");
      return null;
    }
    return null;
  }

  Future<bool?> showSignOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Sign Out',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.blueGrey[900],
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey[700],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context, true); // Return true when user confirms sign out
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context, false); // Return false when user cancels sign out
              },
              child: Text(
                'No',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[700],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> signOut(BuildContext context) async {
    try {
      // Show sign out confirmation dialog
      bool? confirmSignOut = await showSignOutDialog(context);

      if (confirmSignOut == true) {
        // User confirmed sign out

        // Sign out from Firebase
        await _auth.signOut();

        // If signed in with Google, sign out from Google as well
        // if (_googleSignIn.currentsignOutUser != null) {
        //   await _googleSignIn.();
        // }

        // Navigate back to the previous screen or exit the app
        Navigator.pop(context);
      } else {
        // User cancelled sign out, do nothing
      }
    } catch (error) {
      print("Error signing out: $error");
    }
  }

// Method to update user information in Firestore
  Future<void> updateUserInFirestore(
      BuildContext context,
      String? uid,
      String? displayName,
      String? email,
      String? photoURL,
      String firstName,
      String lastName,
      String gender,
      DateTime dob) async {
    try {
      // Update user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'fullName': displayName,
        'photoURL': photoURL,
        'email': email,
        'gender': gender,
        'dob': dob
        // Add other fields as needed
      }, SetOptions(merge: true)); // Merge to only update new fields
      // // ignore: use_build_context_synchronously
      // Navigator.pop(context);
    } catch (error) {
      print("Error updating user in Firestore: $error");
    }
  }

  Future<User?> _handleAccountLinking(FirebaseAuthException error) async {
    try {
      // Retrieve the pending credential from the error
      AuthCredential? pendingCredential = error.credential;
      if (pendingCredential == null) {
        print("Error: No pending credential found.");
        return null;
      }

      // Retrieve the existing user account associated with the email address
      User? existingUser = _auth.currentUser;

      if (existingUser == null) {
        // Prompt the user to sign in with their existing authentication provider
        // For example, you can show a dialog with Google sign-in button
        // After successful sign-in, the user will be linked to their existing account
        // Here, you can use AuthService.signInWithGoogle() method or implement your own logic
        return null; // Return null to indicate waiting for user action
      } else {
        // Link the Facebook credential to the existing user account
        await existingUser.linkWithCredential(pendingCredential);
        return existingUser;
      }
    } catch (linkingError) {
      print("Error linking Facebook credential: $linkingError");
      return null;
    }
  }

  // Inside your login screen or wherever you handle the authentication flow
  void _showErrorMessage(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}
