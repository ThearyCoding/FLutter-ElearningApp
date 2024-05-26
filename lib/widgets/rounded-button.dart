import 'package:flutter/material.dart';

import 'palatte.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    required this.buttonText,
  });

  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            buttonText,
            style: kBodyText,
          ),
        ),
      ),
    );
  }
}
