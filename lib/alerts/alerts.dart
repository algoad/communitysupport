import 'package:flutter/material.dart';
import '../services/firestore.dart';
import '../services/models.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  AlertsScreenState createState() => AlertsScreenState();
}

class AlertsScreenState extends State<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Alert>>(
        future: FirestoreService().getAlerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error.toString()}'),
            );
          } else if (snapshot.hasData) {
            var alerts = snapshot.data!;
            return ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(alerts[index].title),
                  subtitle: Text(
                      '${alerts[index].date}\n${alerts[index].description}'),
                  isThreeLine: true,
                );
              },
            );
          } else {
            return const Center(
              child: Text('No alerts found in Firestore. Check database'),
            );
          }
        },
      ),
    );
  }
}
