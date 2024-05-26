import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeControllerGetxStorage extends GetxController {
  final Rx<ThemeMode> currentTheme = ThemeMode.system.obs;
  final String storageKey = 'isdarkMode';
  final GetStorage _getStorage = GetStorage();
  //  void switchTheme() {
  //   currentTheme.value = currentTheme.value == ThemeMode.light
  //       ? ThemeMode.dark
  //       : ThemeMode.light;
  // }
  @override
  void onInit() {
    super.onInit();
    // Initialize theme mode on app startup
    currentTheme.value = getThemeModeFromStorage();
  }

  // Function to switch between themes
 void switchTheme() {
    currentTheme.value = currentTheme.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    // Save the updated theme mode to GetStorage
    _saveThemeToStorage(currentTheme.value);
  }

  // Function to retrieve theme mode from GetStorage
  ThemeMode getThemeModeFromStorage() {
    // Default to dark theme for new users or if the value is not set
    bool isDarkMode = _getStorage.read(storageKey) ?? false;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // Function to save theme mode to GetStorage
  void _saveThemeToStorage(ThemeMode themeMode) {
    _getStorage.write(storageKey, themeMode == ThemeMode.dark);
  }

  // Function to change the theme mode using Get
  void changeThemeMode() {
    Get.changeThemeMode(getThemeModeFromStorage());
  }
}
