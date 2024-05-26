import 'dart:async';

import 'package:e_leaningapp/Screen/no_internet_page.dart';
import 'package:e_leaningapp/Screen/profile_information.dart';
import 'package:e_leaningapp/Screen/show_allcourses.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:e_leaningapp/Screen/home_page_sliver.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool isConnectedToInternet = true;
  StreamSubscription? _internetConnectionStreamSubscription;
  @override
  void initState() {
    super.initState();
    InternetConnectionCheckerPlus().onStatusChange.listen((event) {
      switch (event) {
        case InternetConnectionStatus.connected:
          setState(() {
            isConnectedToInternet = true;
          });
          break;
        case InternetConnectionStatus.disconnected:
          setState(() {
            isConnectedToInternet = false;
          });
          break;
        default:
          setState(() {
            isConnectedToInternet = false;
          });

          break;
      }
    });
  }

  final List<Widget> _pages = [
    MyHomePage(),
    AllCoursesScreen(),
    const Center(
        child: Text('Notification Page',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold))),
    ProfileInformation()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildIcon(IconData icon, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isConnectedToInternet
        ? Scaffold(
            body: Stack(
              children: _pages
                  .asMap()
                  .map((index, page) {
                    return MapEntry(
                      index,
                      Offstage(
                        offstage: _selectedIndex != index,
                        child: page,
                      ),
                    );
                  })
                  .values
                  .toList(),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.shifting,
              backgroundColor: Colors.white,
              elevation: 2,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: _buildIcon(IconlyBold.home, _selectedIndex == 0),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon(IconlyBold.video, _selectedIndex == 1),
                  label: 'Courses',
                ),
                BottomNavigationBarItem(
                  icon:
                      _buildIcon(IconlyBold.notification, _selectedIndex == 2),
                  label: 'Notifications',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon(IconlyBold.profile, _selectedIndex == 3),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              onTap: _onItemTapped,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        : const NoInternetPage();
  }
}
