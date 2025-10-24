import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class View_near_pink_police extends StatefulWidget {
  @override
  _View_near_pink_policeState createState() => _View_near_pink_policeState();
}

class _View_near_pink_policeState extends State<View_near_pink_police> {
  late Timer _timer;
  Position? _currentPosition;

  List<String> id_ = <String>[];
  List<String> name_ = <String>[];
  List<String> phone_ = <String>[];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _startLocationTracking();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) return;
    }
  }

  void _startLocationTracking() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
    });

    _sendLocationToServer(position);
  }

  Future<void> _sendLocationToServer(Position position) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url').toString();

      final response = await http.post(
        Uri.parse('$url/myapp/View_pink_police/'),
        body: {
          'la': position.latitude.toString(),
          'lo': position.longitude.toString(),
        },
      );

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        String status = jsondata['status'];

        var arr = jsondata["data"];
        List<String> id = <String>[];
        List<String> name = <String>[];
        List<String> phone = <String>[];

        for (int i = 0; i < arr.length; i++) {
          id.add(arr[i]['id'].toString());
          name.add(arr[i]['name'].toString());
          phone.add(arr[i]['phone'].toString());
        }

        setState(() {
          id_ = id;
          name_ = name;
          phone_ = phone;
        });

        print(status);
        print("Location sent successfully!");
      } else {
        print("Failed to send location");
      }
    } catch (e) {
      print("Error sending location: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _makeEmergencyCall(String phoneNumber) async {
    final Uri emergencyUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunch(emergencyUri.toString())) {
      await launch(emergencyUri.toString());
    } else {
      throw 'Could not make the emergency call';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nearest Pink Police"),
        backgroundColor: Color(0xFF0288D1),
        elevation: 10,
      ),
      body: id_.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : ListView.builder(
        itemCount: id_.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name_[index],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      phone_[index],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await _makeEmergencyCall(phone_[index]);
                      },
                      child: Text("Emergency Call",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: View_near_pink_police(),
  theme: ThemeData(
    primarySwatch: Colors.teal,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
));
