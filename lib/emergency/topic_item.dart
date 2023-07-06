import 'dart:async';

import 'package:flutter/material.dart';
import 'package:communitysupport/services/models.dart';
import 'package:url_launcher/url_launcher.dart'; // import url_launcher
import 'package:device_info/device_info.dart';

class TopicItem extends StatelessWidget {
  final Topic topic;

  const TopicItem({Key? key, required this.topic}) : super(key: key);

  Future<void> _launchURL(String? uri, BuildContext context, bool isWebsite) {
    final completer = Completer<void>();
    if (uri != null) {
      if (isWebsite) {
        Uri url = Uri.parse(uri);
        canLaunchUrl(url).then((canLaunch) {
          if (canLaunch) {
            launchUrl(url).then((_) => completer.complete());
          } else {
            completer.completeError('Could not launch $url');
          }
        });
      } else {
        Uri url = Uri.parse("tel:$uri");
        canLaunchUrl(url).then((canLaunch) {
          if (canLaunch) {
            launchUrl(url).then((_) => completer.complete());
          } else {
            completer.completeError('Could not launch $url');
          }
        });
      }
    } else {
      completer.completeError('Uri was null');
    }
    return completer.future;
  }

  Future<bool> _isPhysicalDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.isPhysicalDevice;
  }

  void _launchOrShowSnackbar(
      String? uri, BuildContext context, bool isWebsite) {
    _isPhysicalDevice().then((isPhysicalDevice) {
      if (isPhysicalDevice) {
        _launchURL(uri, context, isWebsite);
      } else {
        const snackBar =
            SnackBar(content: Text('Cannot perform this action on simulator'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: topic.img,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0), // corner radius
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.2),
          //     spreadRadius: 1,
          //     blurRadius: 3,
          //     offset: const Offset(0, 2), // changes position of shadow
          //   ),
          // ],
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: InkWell(
            onTap: () {
              if (topic.website != null) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Call or make a report'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              _launchOrShowSnackbar(
                                  topic.number, context, false);
                            },
                            child: const Text('Call'),
                          ),
                          InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              _launchOrShowSnackbar(
                                  topic.website, context, true);
                            },
                            child: const Text('Report incident'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                _launchOrShowSnackbar(topic.number, context, false);
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    color: const Color.fromARGB(255, 30, 50, 97),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.asset(
                        'assets/covers/${topic.img}',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    color: const Color.fromARGB(255, 30, 50, 97),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 5, left: 10, right: 10),
                      child: Center(
                        child: Text(
                          topic.title,
                          textAlign: TextAlign.center,
                          maxLines: 2, // Set maximum lines to 2
                          overflow: TextOverflow
                              .ellipsis, // Add an ellipsis when the text overflows
                          style: const TextStyle(
                            color: Colors.white,
                            height: 1.0,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
