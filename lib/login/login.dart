import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../services/auth.dart';
import '../services/firestore.dart';
import '../services/models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const FlutterLogo(
              size: 150,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    initialValue: context.watch<UserDataProvider>().name,
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      context.read<UserDataProvider>().name = value;
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: context.watch<UserDataProvider>().phoneNumber,
                    decoration: const InputDecoration(
                      hintText: 'Enter your mobile number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      context.read<UserDataProvider>().phoneNumber = value;
                      return null;
                    },
                  ),
                  LoginButton(
                    icon: FontAwesomeIcons.userNinja,
                    text: 'Login',
                    loginMethod: () async {
                      if (_formKey.currentState!.validate()) {
                        var userData = context.read<UserDataProvider>();
                        await AuthService().anonLogin();
                        await FirestoreService().updateUserData(
                            userData.name, userData.phoneNumber);
                      }
                    },
                    color: Colors.deepPurple,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;

  const LoginButton(
      {super.key,
      required this.text,
      required this.icon,
      required this.color,
      required this.loginMethod});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(24),
          backgroundColor: color,
        ),
        onPressed: () => loginMethod(),
        label: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
