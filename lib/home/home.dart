import 'package:flutter/material.dart';
import 'package:communitysupport/login/login.dart';
import 'package:communitysupport/shared/shared.dart';
import 'package:communitysupport/emergency/emergency.dart';
import 'package:communitysupport/services/auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        } else if (snapshot.hasError) {
          return const Center(
            child: ErrorMessage(),
          );
        } else if (snapshot.hasData) {
          return const EmergencyScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
