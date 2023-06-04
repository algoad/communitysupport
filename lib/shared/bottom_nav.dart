import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/emergency');
          break;
        case 1:
          Navigator.pushNamed(context, '/alerts');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.graduationCap,
            size: 20,
            color: _selectedIndex == 0 ? Colors.deepPurple[200] : Colors.black,
          ),
          label: 'Emergency',
        ),
        BottomNavigationBarItem(
          icon: IgnorePointer(
            ignoring: _selectedIndex == 1,
            child: Icon(
              FontAwesomeIcons.graduationCap,
              size: 20,
              color:
                  _selectedIndex == 1 ? Colors.deepPurple[200] : Colors.black,
            ),
          ),
          label: 'Alerts',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}
