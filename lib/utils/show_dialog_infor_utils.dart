import 'package:flutter/material.dart';

Future<bool?> showExitQuizDialog(
  BuildContext context,
  Function cancelTimer,
  String title,
  String content,
) async {
  return await showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              overlayColor: Colors.grey.shade300
            ),
            
            child:  Text("Cancel",style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge!.color
            ),),
          ),
          ElevatedButton(
            onPressed: () {
              cancelTimer();
              Navigator.pop(context, true);
              Navigator.pop(context, true); // Remove if not needed
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Exit"),
          ),
        ],
      );
    },
  );
}
