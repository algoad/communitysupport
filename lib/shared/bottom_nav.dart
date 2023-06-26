import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  final int currentPage;

  const BottomNavBar({Key? key, required this.currentPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed, // Show labels all the time
        showSelectedLabels: true, // Show selected label
        showUnselectedLabels: true, // Show unselected labels
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              FontAwesomeIcons.phone,
              size: 20,
              color: Color.fromRGBO(4, 15, 57, 1),
            ),
            label: 'EMERGENCY',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              FontAwesomeIcons.bell,
              size: 20,
              color: Color.fromRGBO(4, 15, 57, 1),
            ),
            label: 'ALERTS',
          ),
        ],
        currentIndex: currentPage,
        selectedItemColor:
            const Color.fromRGBO(4, 15, 57, 1), // Color for selected item
        unselectedItemColor:
            const Color.fromRGBO(4, 15, 57, 1), // Color for unselected items
        onTap: (int idx) {
          if (idx == currentPage) {
            // Do nothing if the tapped icon is for the current page.
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
