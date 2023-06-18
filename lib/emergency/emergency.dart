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
import 'package:what3words/what3words.dart';

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
  String _what3words = '';

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
    var api = What3WordsV3('YUCRNHX7');

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

      var words = await api
          .convertTo3wa(
              Coordinates(currentPosition.latitude, currentPosition.longitude))
          .language('en')
          .execute();

      setState(() {
        _what3words = words.data()!.words;
      });

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
    Topic topic1 = Topic(title: "CHS", img: "chs.png", number: "041234567");
    Topic topic2 = Topic(
        title: "CSG",
        img: "csg.png",
        number: "041222222",
        website: 'www.google.com');
    List<Topic> topics = [topic1, topic2];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Emergency'),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Logout'),
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
            latitude: _center.latitude,
            longitude: _center.longitude,
            address: _currentAddress,
            what3words: _what3words,
          ),
          Positioned(
            bottom: 190, //position from the bottom
            left: 20, //position from the left
            right: 20, //position from the right
            child: GestureDetector(
              onTap: () {
                _launchURL('000');
              },
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.red, // red background
                  borderRadius: BorderRadius.circular(10), // rounded corners
                ),
                child: const Text(
                  'Call 000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
        currentPage: 0,
      ),
    );
  }
}
