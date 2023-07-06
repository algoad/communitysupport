import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<bool> _isPhysicalDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.isPhysicalDevice;
  }

  void _launchOrShowSnackbar(String? uri, BuildContext context) {
    _isPhysicalDevice().then((isPhysicalDevice) {
      if (isPhysicalDevice) {
        _launchURL(uri, context);
      } else {
        const snackBar =
            SnackBar(content: Text('Cannot perform this action on simulator'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  Future<void> _launchURL(String? uri, BuildContext context) {
    final completer = Completer<void>();
    if (uri != null) {
      Uri url = Uri.parse("tel:$uri");
      canLaunchUrl(url).then((canLaunch) {
        if (canLaunch) {
          launchUrl(url).then((_) => completer.complete());
        } else {
          completer.completeError('Could not launch $url');
        }
      });
    } else {
      completer.completeError('Uri was null');
    }
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              child: Image.asset(
                'assets/covers/chs_full.png',
                fit: BoxFit.contain,
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    initialValue: context.watch<UserDataProvider>().name,
                    cursorColor: const Color.fromRGBO(
                        29, 45, 91, 1), // Set RGB color for the cursor
                    style: const TextStyle(
                      color: Color.fromRGBO(
                          29, 45, 91, 1), // Set RGB color for the entered text
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(
                            29, 45, 91, 1), // Set RGB color for the hint text
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(29, 45, 91,
                              1), // This color will be used when the TextField is enabled.
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(29, 45, 91,
                              1), // This color will be used when the TextField is selected.
                        ),
                      ),
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
                    cursorColor: const Color.fromRGBO(29, 45, 91, 1),
                    style:
                        const TextStyle(color: Color.fromRGBO(29, 45, 91, 1)),
                    decoration: const InputDecoration(
                      hintText: 'Enter your mobile number',
                      hintStyle:
                          TextStyle(color: Color.fromRGBO(29, 45, 91, 1)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromRGBO(29, 45, 91, 1)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromRGBO(29, 45, 91, 1)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      // Define a basic pattern for mobile numbers. This can be adjusted.
                      Pattern pattern = r'^(?:[+0]9)?[0-9]{10}$';
                      RegExp regex = RegExp(pattern as String);
                      if (!regex.hasMatch(value)) {
                        return 'Please enter a valid mobile number';
                      }
                      context.read<UserDataProvider>().phoneNumber = value;
                      return null;
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10.0), // adjust the value as needed
                  ),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly, // Adjust this as needed.
                    children: <Widget>[
                      Expanded(
                        child: LoginButton(
                          icon: FontAwesomeIcons.arrowRight,
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
                        ),
                      ),
                      const SizedBox(
                          width: 10.0), // Add a SizedBox for spacing.
                      Expanded(
                        child: LoginButton(
                          icon: FontAwesomeIcons.phone,
                          text: 'Call CHS',
                          loginMethod: () async {
                            _launchOrShowSnackbar("0432577179", context);
                          },
                          color: Colors.deepPurple,
                        ),
                      )
                    ],
                  ),
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

  const LoginButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    required this.loginMethod,
  }) : super(key: key);

  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Fluttertoast.showToast(
        msg: "You need internet connection to continue",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      loginMethod();
    }
  }

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
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(const Color.fromRGBO(29, 45, 91, 1)),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // border radius
            ),
          ),
        ),
        onPressed: () => checkConnectivity(),
        label: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
