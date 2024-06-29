import 'package:e_leaningapp/controller/auth_controller.dart';
import 'package:e_leaningapp/export/export.dart';
import 'package:e_leaningapp/widgets/custom_text_field_widget_02.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_button_widget_02.dart';

// ignore: must_be_immutable
class SignUpWithEmailScreen extends StatelessWidget {
  SignUpWithEmailScreen({super.key, required this.onSwitchToLogin});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController controller = Get.put(AuthController());
  final TextEditingController txtemail = TextEditingController();
  final TextEditingController txtpassword = TextEditingController();
  final TextEditingController txtconfirmPassword = TextEditingController();

  final VoidCallback onSwitchToLogin;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async{
        onSwitchToLogin();
        return false;
      },
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomTextFieldWidget02(
                  labelText: 'Email | ',
                  controller: txtemail,
                  validator: (input) {
                    if (input == null || input.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                  obscureText: false,
                  hoverBorderColor: Colors.green,
                  focusedBorderColor: Colors.green,
                  defaultBorderColor: Colors.grey,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextFieldWidget02(
                  labelText: 'Password | ',
                  controller: txtpassword,
                  validator: (input) {
                    if (input == null || input.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  obscureText: true,
                  hoverBorderColor: Colors.green,
                  focusedBorderColor: Colors.green,
                  defaultBorderColor: Colors.grey,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextFieldWidget02(
                  labelText: 'Confirm Password | ',
                  controller: txtconfirmPassword,
                  validator: (input) {
                    if (input == null || input.isEmpty) {
                      return 'Please confirm your password';
                    } else if (input != txtpassword.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  obscureText: true,
                  hoverBorderColor: Colors.green,
                  focusedBorderColor: Colors.green,
                  defaultBorderColor: Colors.grey,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomElevatedButtonWidget02(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            controller.signUp(txtemail.text, txtpassword.text);
                          }
                        },
                  isLoading: controller.isLoading.value,
                  text: 'Sign Up',
                  textColor: Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.black,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                ),
                TextButton(
                  onPressed: onSwitchToLogin,
                  child: Text(
                    "Don't have an account? Sign up here",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
