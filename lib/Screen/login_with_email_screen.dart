import 'package:e_leaningapp/widgets/custom_button_widget_02.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import '../widgets/custom_text_field_widget_02.dart';

class LoginWithEmailScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final VoidCallback onSwitchToSignUp;

  LoginWithEmailScreen({super.key, required this.onSwitchToSignUp});
  final AuthController _loginController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async{
        onSwitchToSignUp();
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
                  controller: _emailController,
                  labelText: 'Email | ',
                  validator: (input) {
                    if (input == null || input.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                  onSaved: (input) => _emailController.text = input!,
                  obscureText: false,
                  hoverBorderColor: Colors.green,
                  focusedBorderColor: Colors.green,
                  defaultBorderColor: Colors.grey,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextFieldWidget02(
                  controller: _passwordController,
                  labelText: 'Password | ',
                  validator: (input) {
                    if (input == null || input.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onSaved: (input) => _passwordController.text = input!,
                  obscureText: true,
                  hoverBorderColor: Colors.green,
                  focusedBorderColor: Colors.green,
                  defaultBorderColor: Colors.grey,
                ),
                const SizedBox(height: 20),
                CustomElevatedButtonWidget02(
                  onPressed:  () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _loginController.login(
                              _emailController.text,
                              _passwordController.text,
                            );
                          }
                        },
                  text: 'Login',
                  textColor: Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.black,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                  isLoading: _loginController.isLoading.value,
                ),
                TextButton(
                  onPressed: onSwitchToSignUp,
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
