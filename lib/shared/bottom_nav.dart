import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  final int currentPage;

  const BottomNavBar({Key? key, required this.currentPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation:
          10.0, // Set the elevation, adjust to achieve desired shadow effect
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(
                FontAwesomeIcons.phone,
                size: 20,
                color: Color.fromRGBO(4, 15, 57, 1),
              ),
            ),
            label: 'EMERGENCY',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(
                FontAwesomeIcons.solidBell,
                size: 20,
                color: Color.fromRGBO(4, 15, 57, 1),
              ),
            ),
            label: 'ALERTS',
          ),
        ],
        currentIndex: currentPage,
        selectedItemColor: const Color.fromRGBO(4, 15, 57, 1),
        unselectedItemColor: const Color.fromRGBO(220, 220, 220, 1),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
        ),
        onTap: (int idx) {
          if (idx == currentPage) {
            return;
          }
          switch (idx) {
            case 0:
              Navigator.pushReplacementNamed(context, '/emergency');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/alerts');
              break;
          }
        },
      ),
    );
  }
}
