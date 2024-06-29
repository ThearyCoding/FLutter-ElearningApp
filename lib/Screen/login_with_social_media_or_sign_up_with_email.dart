import 'package:e_leaningapp/Screen/login_screen.dart';
import 'package:e_leaningapp/Screen/login_with_email_screen.dart';
import 'package:e_leaningapp/Screen/sign_up_with_email_screen.dart';
import 'package:flutter/material.dart';


class LoginwithSocialMedailOrSignUpWithEmail extends StatefulWidget {
  const LoginwithSocialMedailOrSignUpWithEmail({super.key});

  @override
  State<LoginwithSocialMedailOrSignUpWithEmail> createState() => _LoginwithSocialMedailOrSignUpWithEmailState();
}

class _LoginwithSocialMedailOrSignUpWithEmailState extends State<LoginwithSocialMedailOrSignUpWithEmail> {
  bool _showLoginScreen = true;
  bool _showLoginWithEmailScreen = false;

  void _toggleToSignUp() {
    setState(() {
      _showLoginScreen = false;
      _showLoginWithEmailScreen = false;
    });
  }

  void _toggleToLoginWithEmail() {
    setState(() {
      _showLoginWithEmailScreen = true;
    });
  }

  void _toggleToLoginScreen() {
    setState(() {
      _showLoginScreen = true;
      _showLoginWithEmailScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showLoginWithEmailScreen) {
      return LoginWithEmailScreen(onSwitchToSignUp: _toggleToLoginScreen,);
    } else if (!_showLoginScreen) {
      return SignUpWithEmailScreen(onSwitchToLogin: _toggleToLoginScreen);
    } else {
      return LoginScreen(
        onSwitchToSignUp: _toggleToSignUp,
        onSwitchToLogin: _toggleToLoginWithEmail,
      );
    }
  }
}
