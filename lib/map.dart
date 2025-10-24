import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nearby Police Map',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng userLocation = LatLng(0, 0);
  List<LatLng> nearbyPolice = [];
  late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // Listen to location updates
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        _updateNearbyPolice();
      });
    });
  }

  // Mock nearby police locations (update dynamically)
  void _updateNearbyPolice() {
    nearbyPolice = [
      LatLng(userLocation.latitude + 0.001, userLocation.longitude + 0.001),
      LatLng(userLocation.latitude - 0.0015, userLocation.longitude + 0.002),
      LatLng(userLocation.latitude + 0.002, userLocation.longitude - 0.001),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Police Map")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: userLocation,
          minZoom: 16,// use initialCenter instead of center
          maxZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.shecare',
          ),



          MarkerLayer(
            markers: [
              Marker(
                point: userLocation,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
              for (var police in nearbyPolice)
                Marker(
                  point: police,
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.local_police,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
            ],
          ),
        ],
      )

    );
  }
}
