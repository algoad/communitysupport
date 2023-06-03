import 'package:communitysupport/about/about.dart';
import 'package:communitysupport/profile/profile.dart';
import 'package:communitysupport/login/login.dart';
import 'package:communitysupport/topics/topics.dart';
import 'package:communitysupport/home/home.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/topics': (context) => const TopicsScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/about': (context) => const AboutScreen(),
};
