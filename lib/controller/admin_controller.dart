import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../export/export.dart';

class AdminController extends GetxController {
  final RxList<AdminModel> admins = <AdminModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdmins();
  }

  void fetchAdmins() {
    try {
      isLoading.value = true;
      FirebaseFirestore.instance.collection('admins').snapshots().listen(
        (adminQuery) {
          admins.value = adminQuery.docs
              .map((doc) => AdminModel.fromJson(doc.data()))
              .toList();
          isLoading.value = false;
        },
        onError: (error) {
          // Handle other errors that might occur
          if (kDebugMode) {
            print('Error fetching admins: $error');
          }
          isLoading.value = false;
          showError('An unexpected error occurred. Please try again.');
        },
      ).onError((error) {
        if (error is SocketException) {
          if (kDebugMode) {
            print('No internet connection: $error');
          }
          showError('No internet connection. Please check your network.');
        } else if (error is TimeoutException) {
          if (kDebugMode) {
            print('Connection timed out: $error');
          }
          showError('Connection timed out. Please try again.');
        } else {
          if (kDebugMode) {
            print('Unknown error: $error');
          }
          showError('An unknown error occurred. Please try again.');
        }
        isLoading.value = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching admins: $e');
      }
      showError('An unexpected error occurred. Please try again.');
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
