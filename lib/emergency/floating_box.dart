import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FloatingBox extends StatelessWidget {
  final String address;
  final bool locationDenied;

  const FloatingBox({
    Key? key,
    required this.address,
    required this.locationDenied,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Tell the operator your location',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        address,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      if (locationDenied)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              PermissionStatus permissionStatus =
                                  await Permission.locationWhenInUse.status;

                              switch (permissionStatus) {
                                case PermissionStatus.denied:
                                  permissionStatus = await Permission
                                      .locationWhenInUse
                                      .request();
                                  break;
                                case PermissionStatus.permanentlyDenied:
                                  openAppSettings();
                                  break;
                                default:
                                  break;
                              }

                              if (kDebugMode) {
                                print(
                                    "Permission status after requesting: $permissionStatus");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text('Allow location'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
