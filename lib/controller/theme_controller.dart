import 'package:flutter/material.dart';
import '../export/export.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> currentTheme = ThemeMode.system.obs;
  final String storageKey = 'isdarkMode';
  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    // Initialize shared_preferences
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    currentTheme.value = getThemeModeFromStorage();
  }

  // Function to switch between themes
  void switchTheme() {
    currentTheme.value = currentTheme.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    // Save the updated theme mode to shared_preferences
    _saveThemeToStorage(currentTheme.value);

    // Apply the new theme mode
    Get.changeThemeMode(currentTheme.value);
  }

  // Function to retrieve theme mode from shared_preferences
  ThemeMode getThemeModeFromStorage() {
    // Default to dark theme for new users or if the value is not set
    bool isDarkMode = _prefs?.getBool(storageKey) ?? true;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // Function to save theme mode to shared_preferences
  void _saveThemeToStorage(ThemeMode themeMode) {
    _prefs?.setBool(storageKey, themeMode == ThemeMode.dark);
  }

  // Function to change the theme mode using Get
  void changeThemeMode() {
    Get.changeThemeMode(getThemeModeFromStorage());
  }
}
