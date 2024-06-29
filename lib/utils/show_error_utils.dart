 import 'package:flutter/material.dart';

import '../export/export.dart';

void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

void showSnackbar(String title, String message, {IconData? icon, Color? backgroundColor}) {
    Get.snackbar(
      title,
      message,
      icon: icon != null ? Icon(icon, color: Colors.white) : null,
      backgroundColor: backgroundColor ?? Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }