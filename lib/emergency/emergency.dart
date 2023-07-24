import 'package:communitysupport/emergency/topic_item.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:communitysupport/shared/shared.dart';
import '../services/auth.dart';
import '../services/models.dart';
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

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getCurrentUserLocation();
  }

  Future<void> _getCurrentUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request');
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
        website: 'https://www.csgnsw.org.au/report-something');
    List<Topic> topics = [topic1, topic2];

    Future<void> checkConnectivity() async {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        Fluttertoast.showToast(
          msg: "You need internet connection to continue",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        await AuthService().signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 30, 50, 97),
        title: const Text('Community Safe'),
        actions: <Widget>[
          TextButton(
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: () => checkConnectivity(),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            }, // Enable dragging
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
