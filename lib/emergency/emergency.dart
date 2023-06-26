import 'package:communitysupport/emergency/topic_item.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:communitysupport/shared/shared.dart';
import '../services/auth.dart';
import '../services/models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'floating_box.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  MyEmergencyState createState() => MyEmergencyState();
}

class MyEmergencyState extends State<EmergencyScreen> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(-33.886, 151.27);
  final Set<Marker> _markers = {};
  String _currentAddress = '';
  final String _what3words = '';

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getCurrentUserLocation();
  }

  void _launchURL(String phoneNumber) async {
    Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _getCurrentUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
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
      _updateAddress(currentPosition.latitude, currentPosition.longitude);

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
        _markers.add(
          Marker(
            markerId: const MarkerId('1'), // Unique id for marker
            position: LatLng(currentPosition.latitude,
                currentPosition.longitude), // lat and long for the marker
          ),
        );
      });
    } else {
      return Future.error('Location services are disabled');
    }
  }

  Future<void> _updateAddress(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];
    setState(() {
      _currentAddress = "${place.street}, ${place.locality}, ${place.country}";
    });
  }

  @override
  Widget build(BuildContext context) {
    Topic topic1 = Topic(
        title: "Call for medical assistance",
        img: "chs.png",
        number: "0432577179");
    Topic topic2 = Topic(
        title: "Contact security",
        img: "csg.png",
        number: "0432577178",
        website: 'www.google.com');
    List<Topic> topics = [topic1, topic2];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        title: const Text('Emergency'),
        actions: <Widget>[
          TextButton(
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await AuthService().signOut();
              if (mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            markers: _markers,
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
          FloatingBox(
            address: _currentAddress,
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
        currentPage: 0,
      ),
    );
  }
}
