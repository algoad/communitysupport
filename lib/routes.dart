import 'package:communitysupport/alerts/alerts.dart';
import 'package:communitysupport/login/login.dart';
import 'package:communitysupport/home/home.dart';
import 'package:communitysupport/emergency/emergency.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/emergency': (context) => const EmergencyScreen(),
  '/alerts': (context) => const AlertsScreen(),
};
