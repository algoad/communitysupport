import 'package:communitysupport/emergency/topic_item.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:communitysupport/shared/shared.dart';
import '../services/models.dart';
import 'floating_box.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  MyTopicsState createState() => MyTopicsState();
}

class MyTopicsState extends State<EmergencyScreen> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(-33.886, 151.27);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getCurrentUserLocation();
  }

  Future<void> _getCurrentUserLocation() async {
    // PermissionStatus permission = await Permission.locationWhenInUse.status;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      // Position position = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanetly denined, we cannot request');
      }
      Position currentPosition = await Geolocator.getCurrentPosition();
      setState(() {
        _center = LatLng(currentPosition.latitude, currentPosition.longitude);
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target:
                    LatLng(currentPosition.latitude, currentPosition.longitude),
                zoom: 17.0),
          ),
        );
      });
    } else {
      return Future.error('Location services are disabled');
    }
  }

  @override
  Widget build(BuildContext context) {
    Topic topic1 = Topic(title: "CHS", img: "chs.png", number: "041234567");
    Topic topic2 = Topic(title: "CSG", img: "csg.png", number: "041222222");
    List<Topic> topics = [topic1, topic2];

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
            children: topics.map((topic) => TopicItem(topic: topic)).toList(),
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
  }
}
