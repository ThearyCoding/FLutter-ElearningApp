import 'package:e_leaningapp/FirebaseService/auth_service_google.dart';
import 'package:e_leaningapp/FirebaseService/auth_service_facebook.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../widgets/widgets.dart';

class LoginPage extends StatelessWidget {
  final AuthServiceGoogle _authService = AuthServiceGoogle();
  final AuthServiceFacebook _authServiceFacebook = AuthServiceFacebook();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackgroundImage(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome to App E-learning',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Discover, Learn, and Grow with us.',
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          speed: const Duration(milliseconds: 50),
                        ),
                        TypewriterAnimatedText(
                          'Spark Your Curiosity!',
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                          ),
                          speed: const Duration(milliseconds: 50),
                        ),
                        TypewriterAnimatedText(
                          'Let\'s Dive In!',
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                          ),
                          speed: const Duration(milliseconds: 50),
                        ),
                        TypewriterAnimatedText(
                          'Welcome to the Adventure!',
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                          ),
                          speed: const Duration(milliseconds: 50),
                        ),
                        TypewriterAnimatedText(
                          'Get Ready to Grow!',
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.orange,
                          ),
                          speed: const Duration(milliseconds: 50),
                        ),
                        TypewriterAnimatedText(
                          'Unlock Your Potential!',
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.purple,
                          ),
                          speed: const Duration(milliseconds: 50),
                        ),
                      ],
                      repeatForever: true,
                    ),
                    const SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              final user = await _authService.signInWithGoogle(context);
                              if (user != null) {
                                print('Signed in as: ${user.displayName}');
                              } else {
                                print('Sign-in failed.');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black, backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/google-removebg-preview.png',
                                  height: 32,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Log in with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              final user = await _authServiceFacebook.loginWithFacebook(context);
                              if (user != null) {
                                print('Signed in as: ${user.user!.displayName}');
                              } else {
                                print('Sign-in failed.');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black, backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/fb-removebg-preview.png',
                                  height: 32,
                                ),
                                const Text(
                                  'Log in with Facebook',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
