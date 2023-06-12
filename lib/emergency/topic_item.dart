import 'package:flutter/material.dart';
import 'package:communitysupport/services/models.dart';
import 'package:url_launcher/url_launcher.dart'; // import url_launcher

class TopicItem extends StatelessWidget {
  final Topic topic;
  const TopicItem({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: topic.img,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 2.0),
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => TopicScreen(topic: topic),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  flex: 3,
                  child: SizedBox(
                    child: Image.asset(
                      'assets/covers/${topic.img}',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    color: Colors.red, // This adds the red background
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Center(
                        child: Text(
                          topic.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors
                                .white, // Changing the text color to white for visibility
                            height: 1.0,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.fade,
                          softWrap: false,
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
