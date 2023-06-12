import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  final int currentPage;

  const BottomNavBar({Key? key, required this.currentPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.kitMedical,
            size: 20,
          ),
          label: 'Emergency',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.bolt,
            size: 20,
          ),
          label: 'Alerts',
        ),
      ],
      currentIndex: currentPage,
      fixedColor: Colors.deepPurple[200],
      onTap: (int idx) {
        if (idx == currentPage) {
          // Do nothing if the tapped icon is for the current page.
          return;
        }
        switch (idx) {
          case 0:
            Navigator.pushNamed(context, '/emergency');
            break;
          case 1:
            Navigator.pushNamed(context, '/alerts');
            break;
        }
      },
    );
  }
}
