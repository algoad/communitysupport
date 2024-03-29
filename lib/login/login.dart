import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
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

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

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

  _requestLocationPermission() async {
    PermissionStatus permissionStatus =
        await Permission.locationWhenInUse.status;

    if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
      permissionStatus = await Permission.locationWhenInUse.request();
      if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
        if (kDebugMode) {
          print("User denied location permission.");
        }
      }
    }
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
                    cursorColor: const Color.fromRGBO(29, 45, 91, 1),
                    style: const TextStyle(
                      color: Color.fromRGBO(29, 45, 91, 1),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(29, 45, 91, 1),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(29, 45, 91, 1),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(29, 45, 91, 1),
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
                    padding: EdgeInsets.all(10.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: LoginButton(
                          icon: FontAwesomeIcons.rightToBracket,
                          text: 'Login',
                          shouldCheckConnectivity: true,
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
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: LoginButton(
                          icon: FontAwesomeIcons.phone,
                          text: 'Call CHS',
                          shouldCheckConnectivity: false,
                          loginMethod: () async {
                            _launchOrShowSnackbar("0432577179", context);
                          },
                          color: Colors.deepPurple,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: LoginButton(
                          icon: FontAwesomeIcons.arrowRight,
                          text: 'Continue without saving details',
                          shouldCheckConnectivity: false,
                          loginMethod: () async {
                            if (mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/emergency', (route) => false);
                            }
                          },
                          color: Colors.deepPurple,
                        ),
                      ),
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
  final bool shouldCheckConnectivity;
  final Function loginMethod;

  const LoginButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    required this.loginMethod,
    required this.shouldCheckConnectivity,
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
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        onPressed: () => {
          if (shouldCheckConnectivity)
            {
              checkConnectivity(),
            }
          else
            {loginMethod()}
        },
        label: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
