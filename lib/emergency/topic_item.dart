import 'package:flutter/material.dart';
import 'package:communitysupport/services/models.dart';
import 'package:url_launcher/url_launcher.dart'; // import url_launcher

class TopicItem extends StatelessWidget {
  final Topic topic;

  const TopicItem({Key? key, required this.topic}) : super(key: key);

  void _launchURL(String? uri) async {
    if (uri != null) {
      Uri url = Uri.parse("tel:$uri");
      // Uri url = Uri.parse(uri);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: topic.img,
      child: Card(
        clipBehavior: Clip.antiAlias,
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
                          onTap: () {
                            Navigator.pop(context);
                            _launchURL(topic.number);
                          },
                          child: const Text('Call'),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _launchURL(topic.website);
                          },
                          child: const Text('Open Website'),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              _launchURL(topic.number);
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
    );
  }
}

class TopicScreen extends StatelessWidget {
  final Topic topic;

  const TopicScreen({super.key, required this.topic});

  void _launchURL(String? uri) async {
    if (uri != null) {
      Uri url = Uri.parse("tel:$uri");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          Hero(
            tag: topic.img,
            child: Image.asset(
              'assets/covers/${topic.img}',
              width: MediaQuery.of(context).size.width,
            ),
          ),
          InkWell(
            onTap: () {
              _launchURL('tel:${topic.number}');
            },
            child: Text(
              'Call ${topic.title}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 20,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          // The conditional expression to display the report button only if topic.website is not null
          topic.website != null
              ? InkWell(
                  onTap: () {
                    _launchURL(topic.website);
                  },
                  child: Text(
                    'Report to ${topic.title}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 20,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : Container(), // If the website is null, we render an empty container.
        ],
      ),
    );
  }
}
