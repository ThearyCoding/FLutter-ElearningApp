import 'package:flutter/material.dart';
import '../export/export.dart';

class LoginScreen extends StatelessWidget {
  final AuthServiceGoogle _authService = AuthServiceGoogle();
  final AuthServiceFacebook _authServiceFacebook = AuthServiceFacebook();
  final VoidCallback? onSwitchToSignUp;
  final VoidCallback? onSwitchToLogin;

  LoginScreen({super.key, this.onSwitchToSignUp, this.onSwitchToLogin});

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
                    const CustomTextAnimationWidget(
                      texts: [
                        'Learn with Us',
                        'Grow Your Skills',
                        'Explore New Topics',
                        'Join the Community',
                        'Enhance Your Knowledge',
                        'Achieve Your Goals',
                      ],
                      textStyles: [
                        TextStyle(fontSize: 18, color: Colors.white),
                        TextStyle(fontSize: 18, color: Colors.green),
                        TextStyle(fontSize: 18, color: Colors.blue),
                        TextStyle(fontSize: 18, color: Colors.red),
                        TextStyle(fontSize: 18, color: Colors.orange),
                        TextStyle(fontSize: 18, color: Colors.purple),
                      ],
                      speed: Duration(milliseconds: 50),
                      repeatForever: true,
                    ),
                    const SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          CustomButtonWidget(
                            text: 'Continue with email',
                            bgcolor: const Color.fromARGB(255, 35, 110, 241),
                            labelColor:
                                Theme.of(context).textTheme.bodyLarge!.color,
                            onPressed: () {
                              if (onSwitchToLogin != null) {
                                onSwitchToLogin!();
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'Or connect with',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CustomButtonWidget(
                            bgcolor: Colors.white,
                            text: 'Login with Google',
                            onPressed: () async {
                              final user =
                                  await _authService.signInWithGoogle(context);
                              if (user != null) {
                                if (kDebugMode) {
                                  print('Signed in as: ${user.displayName}');
                                }
                              } else {
                                if (kDebugMode) {
                                  print('Sign-in failed.');
                                }
                              }
                            },
                            imagePath: 'assets/google-removebg-preview.png',
                          ),
                          const SizedBox(height: 20),
                          CustomButtonWidget(
                            labelColor: Colors.black87,
                            bgcolor: Colors.white,
                            text: 'Login with Facebook',
                            onPressed: () async {
                              final user = await _authServiceFacebook
                                  .loginWithFacebook(context);
                              if (user != null) {
                                if (kDebugMode) {
                                  print(
                                      'Signed in as: ${user.user!.displayName}');
                                }
                              } else {
                                if (kDebugMode) {
                                  print('Sign-in failed.');
                                }
                              }
                            },
                            imagePath: 'assets/fb-removebg-preview.png',
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Create new account?',
                                style: TextStyle(fontSize: 15),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              TextButton(
                                onPressed: onSwitchToSignUp ?? () {},
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                      color: Colors.blueAccent, fontSize: 16),
                                ),
                              )
                            ],
                          )
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
