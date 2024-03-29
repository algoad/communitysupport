import 'package:flutter/material.dart';
import '../services/firestore.dart';
import '../services/models.dart';
import '../shared/bottom_nav.dart';
import 'alert_item.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  AlertsScreenState createState() => AlertsScreenState();
}

class AlertsScreenState extends State<AlertsScreen> {
  Future<List<Alert>> _alertsFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _refreshAlerts();
  }

  Future<List<Alert>> _fetchAlerts() async {
    return await FirestoreService().getAlerts();
  }

  Future<void> _refreshAlerts() async {
    setState(() {
      _alertsFuture = _fetchAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(
        currentPage: 1,
      ),
      body: FutureBuilder<List<Alert>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error.toString()}'),
            );
          } else if (snapshot.hasData) {
            var alerts = snapshot.data!;
            if (alerts.isEmpty) {
              return const Center(
                child:
                    Text('No alerts available', style: TextStyle(fontSize: 18)),
              );
            } else {
              return RefreshIndicator(
                onRefresh: _refreshAlerts,
                child: ListView.separated(
                  itemCount: alerts.length,
                  separatorBuilder: (context, index) => Container(
                    height: 1,
                    color: Colors.grey, // Set the color of the divider to grey
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              height: MediaQuery.of(context).size.height,
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24.0),
                                  topRight: Radius.circular(24.0),
                                ),
                              ),
                              child: AlertItem(alert: alerts[index]),
                            );
                          },
                        );
                      },
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                alerts[index].title,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              alerts[index].date,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          } else {
            return const Center(
              child: Text('No alerts'),
            );
          }
        },
      ),
    );
  }
}
