import 'package:communitysupport/services/models.dart';
import 'package:communitysupport/topics/topic_item.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:communitysupport/shared/shared.dart';
import '../services/firestore.dart';
import 'floating_box.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({Key? key}) : super(key: key);

  @override
  MyTopicsState createState() => MyTopicsState();
}

class MyTopicsState extends State<TopicsScreen> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getCurrentUserLocation();
  }

  Future<void> _getCurrentUserLocation() async {
    PermissionStatus permission = await Permission.locationWhenInUse.status;
    if (permission.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _center, zoom: 11.0),
          ),
        );
      });
    } else if (permission.isDenied) {
      print("PERMISSION DENINED");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Topic>>(
      future: FirestoreService().getTopics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        } else if (snapshot.hasError) {
          return Center(
            child: ErrorMessage(message: snapshot.error.toString()),
          );
        } else if (snapshot.hasData) {
          var topics = snapshot
              .data!; // note that we use ! cause we know there are topics in our database

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.deepPurple,
              title: const Text('Topics'),
            ),
            body: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 14.0,
                  ),
                ),
                GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(20.0),
                  crossAxisSpacing: 10.0,
                  crossAxisCount: 2,
                  children:
                      topics.map((topic) => TopicItem(topic: topic)).toList(),
                ),
                const FloatingBox(
                  latitude: 40.7128,
                  longitude: -74.0060,
                  address: 'New York, NY',
                  what3words: 'index.home.raft',
                ),
              ],
            ),
            bottomNavigationBar: const BottomNavBar(),
          );
        } else {
          return const Text('No topics found in Firestore. Check database');
        }
      },
    );
  }
}
