import 'package:flutter/material.dart';
import '../services/models.dart';

class AlertItem extends StatelessWidget {
  final Alert alert;
  const AlertItem({Key? key, required this.alert}) : super(key: key);

  List<Widget> getParagraphs(String text) {
    return text.split('\\n').expand((paragraph) {
      return [
        Text(
          paragraph,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
      ];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                alert.title,
                style: const TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ...getParagraphs(alert.description),
            ],
          ),
        ),
      ),
    );
  }
}
