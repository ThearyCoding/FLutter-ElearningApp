import 'package:flutter/material.dart';

class CustomDatePicker extends StatelessWidget {
  final String selectedValue;
  final Function onPressed;

  const CustomDatePicker({
    Key? key,
    required this.selectedValue,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: InputBorder.none, 
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                controller: TextEditingController(text: selectedValue),
                readOnly: true, // Make the field read-only
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => onPressed(), // Trigger date picker function
            ),
          ],
        ),
      ),
    );
  }
}
