import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServiceGoogle {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Please wait...',);

      // Sign out the current user if any
      await _googleSignIn.signOut();

      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        // User canceled the sign-in process
        // Dismiss the dialog
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
      // Handle errors
      print("Error signing in with Google: $error");

      // Show an error dialog
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                const Text('An error occurred while signing in with Google.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      return null;
    }finally{
      EasyLoading.dismiss();
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
  void _signoutDailog(BuildContext context){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: CircularProgressIndicator(),
      content: Text("Sign Out.."),
    ));
  }
  // Sign out method
  Future<void> signOut(BuildContext context) async {
    try {
      // Show sign out confirmation dialog
      bool? confirmSignOut = await showSignOutDialog(context);
      
      if (confirmSignOut == true) {
        // User confirmed sign out

        
        // Sign out from Firebase
        await _auth.signOut();

        // If signed in with Google, sign out from Google as well
        if (_googleSignIn.currentUser != null) {
          await _googleSignIn.signOut();
        }

        // Navigate back to the previous screen or exit the app
        Navigator.pop(context);
      } else {
        // User cancelled sign out, do nothing
      }
    } catch (error) {
      print("Error signing out: $error");
    }
  }

  // Get current user
  User? getCurrentUser() {
    try {
      return _auth.currentUser;
    } catch (error) {
      print("Error getting current user: $error");
      return null;
    }
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
