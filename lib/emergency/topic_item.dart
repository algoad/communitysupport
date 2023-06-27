import 'package:flutter/material.dart';
import 'package:communitysupport/services/models.dart';
import 'package:url_launcher/url_launcher.dart'; // import url_launcher
import 'package:device_info/device_info.dart';

class TopicItem extends StatelessWidget {
  final Topic topic;

  const TopicItem({Key? key, required this.topic}) : super(key: key);

  void _launchURL(String? uri, BuildContext context) async {
    if (uri != null) {
      Uri url = Uri.parse("tel:$uri");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        final snackBar = SnackBar(content: Text('Could not launch $url'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<bool> _isPhysicalDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.isPhysicalDevice;
  }

  Future<void> _launchOrShowSnackbar(String? uri, BuildContext context) async {
    if (await _isPhysicalDevice()) {
      _launchURL(uri, context);
    } else {
      const snackBar =
          SnackBar(content: Text('Cannot perform this action on simulator'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: topic.img,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0), // corner radius
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
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
                      title: const Text('Choose an Option'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              await _launchOrShowSnackbar(
                                  topic.number, context);
                            },
                            child: const Text('Call'),
                          ),
                          InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              await _launchOrShowSnackbar(
                                  topic.website, context);
                            },
                            child: const Text('Open Website'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                _launchOrShowSnackbar(topic.number, context);
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    color: const Color.fromARGB(255, 30, 50, 97),
                    child: Image.asset(
                      'assets/covers/${topic.img}',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    color: const Color.fromARGB(255, 30, 50, 97),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
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
