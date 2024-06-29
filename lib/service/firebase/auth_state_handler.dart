import 'package:e_leaningapp/Screen/login_with_social_media_or_sign_up_with_email.dart';
import 'package:flutter/material.dart';

import '../../export/export.dart';

class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (snapshot.connectionState == ConnectionState.active) {
          User? currentUser = snapshot.data;

          // Check if the user is authenticated
          if (currentUser != null) {
            // Access isLoggedIn from LocalStorageSharedPreferences controller
            bool isLoggedIn =
                Get.find<LocalStorageSharedPreferences>().isLoggedIn.value;

            if (isLoggedIn) {
              return const HomeScreen();
            } else {
              // User not authenticated, navigate to LoginPage
              return FutureBuilder<bool>(
                future:
                    FirebaseService().isInformationComplete(currentUser).first,
                builder: (context, infoSnapshot) {
                  if (infoSnapshot.connectionState == ConnectionState.waiting) {
                    // Information completeness is being verified, show loading indicator
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  } else {
                    if (infoSnapshot.data == true) {
                      Get.find<LocalStorageSharedPreferences>()
                          .saveUserLoginStatus(true);
                      // User authenticated and information is complete, navigate to HomePage
                      return const HomeScreen();
                    } else {
                      // User authenticated but information is not complete, stay on CompleteInfo1 page
                      return const CompleteInformations();
                    }
                  }
                },
              );
            }
          } else {
            // User not authenticated, navigate to LoginPage
            return LoginwithSocialMedailOrSignUpWithEmail();
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
        return LoginwithSocialMedailOrSignUpWithEmail();
      },
    );
  }
}