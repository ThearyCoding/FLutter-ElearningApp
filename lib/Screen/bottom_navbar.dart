import 'package:e_leaningapp/Screen/profile_information_screen.dart';
import '../export/export.dart';
import 'home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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

  void _onProfileImageTapped() {
    setState(() {
      _selectedIndex = 3;
    });
  }
  void _onSeeAllCourses(){
    setState(() {
      _selectedIndex = 1;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Offstage(
            offstage: _selectedIndex != 0,
            child: MyHomePage(
              onSeeAllCoursesTapped: _onSeeAllCourses,
              onProfileImageTapped: _onProfileImageTapped,
            
            )),
        Offstage(offstage: _selectedIndex != 1, child: AllCoursesScreen()),
        Offstage(
          offstage: _selectedIndex != 2,
          child: const Center(
              child: Text('Notification Page',
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold))),
        ),
        Offstage(
            offstage: _selectedIndex != 3, child: const ProfileInformation()),
      ]),
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
            icon: _buildIcon(IconlyBold.notification, _selectedIndex == 2),
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
    );
  }
}
