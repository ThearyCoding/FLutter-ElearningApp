import 'package:flutter/material.dart';

class CustomThemes {
  static final lightTheme = ThemeData(
    primaryColor: Colors.blue,
    useMaterial3: false,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(background: Color(0xffECECEC),secondary: Colors.grey[300]!,),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      iconTheme: IconThemeData(color: Colors.white), // AppBar icon color
    ),
     textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black), // General text color
      bodyMedium: TextStyle(color: Colors.black87), // Secondary text color
      displayLarge: TextStyle(color: Colors.black), // Headline text color
      // Define other text styles as needed
    ),
    primaryTextTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black), // Primary text color
      bodyMedium: TextStyle(color: Colors.black87), // Secondary text color
      displayLarge: TextStyle(color: Colors.black), // Headline text color
      // Define other text styles as needed
    ),
    iconTheme: IconThemeData(color: Colors.black), // General icon color
    primaryIconTheme: IconThemeData(color: Colors.black), // Primary icon color
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.blue,
            width: 3.0,
          ),
        ),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: Colors.blueGrey,
    useMaterial3: false,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xff171717),
    colorScheme: ColorScheme.dark(
      background: Color(0xff212121),
      secondary: Colors.grey[500]!,
      
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueGrey,
      iconTheme: IconThemeData(color: Colors.white), // AppBar icon color
    ),
     textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white), // General text color
      bodyMedium: TextStyle(color: Colors.white70), // Secondary text color
      displayLarge: TextStyle(color: Colors.white), // Headline text color
      // Define other text styles as needed
    ),
    primaryTextTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white), // Primary text color
      bodyMedium: TextStyle(color: Colors.white70), // Secondary text color
      displayLarge: TextStyle(color: Colors.white), // Headline text color
      // Define other text styles as needed
    ),
    iconTheme: IconThemeData(color: Colors.white.withOpacity(.9)), // General icon color
    primaryIconTheme: IconThemeData(color: Colors.white.withOpacity(.9)), // Primary icon color
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.blueGrey,
      unselectedLabelColor: Colors.grey,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.blueGrey,
            width: 3.0,
          ),
        ),
      ),
    ),
  );
}
