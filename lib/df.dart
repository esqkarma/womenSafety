import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shecare/login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volume Watcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VolumeWatcher(),
    );
  }
}

class VolumeWatcher extends StatefulWidget {
  const VolumeWatcher({super.key});

  @override
  _VolumeWatcherState createState() => _VolumeWatcherState();
}

class _VolumeWatcherState extends State<VolumeWatcher> {
  static const platform = MethodChannel('com.example.volumeWatcher'); // The channel name
  String _volume = "Unknown";

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _startLocationTracking();
    // Setting up the channel to listen for volume changes
    platform.setMethodCallHandler(_handleMethod);
  }

  Future<void> _handleMethod(MethodCall call) async {
    if (call.method == "volumeChanged") {

      _sendData(lo.toString(),la.toString());

      print("volume changed");
      print(call.arguments.toString());


      const phoneNumber = 'tel:8606084336';  // Replace with the phone number
      if (await canLaunch(phoneNumber)) {
        await launch(phoneNumber);
      } else {
        print("no call");
        throw 'Could not dial $phoneNumber';
      }





      Fluttertoast.showToast(msg: "volume changed");
      // When volume changes, update the UI with the new volume level
      setState(() {
        _volume = call.arguments.toString();
      });
    }
  }
  TextEditingController ipcontroller= new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Volume Watcher")),
      body:  Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: ipcontroller,
                decoration: InputDecoration(labelText: 'IPaddress',border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),),
            ),
            ElevatedButton(onPressed: () async {

              String ip=ipcontroller.text.toString();

              SharedPreferences sh=await SharedPreferences.getInstance();
              sh.setString("url", "http://"+ip+":8000");

              Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));

            }, child: Text("Save settings"))


          ],
        ),
      ),
    );
  }
  Future<void> _sendData(String long,String lat) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = prefs.getString('url') ?? '';
    String lid = prefs.getString('lid') ?? '';

    final response = await http.post(
      Uri.parse('$url/myapp/user_add_emergency_request/'),
      body: {
        'lid': lid,
        'la': lat,
        'lo': long,
      },
    );

    if (response.statusCode == 200) {
      String status = jsonDecode(response.body)['status'];
      if (status == 'ok') {
        // Fluttertoast.showToast(msg: 'Dangerous Spot Added Successfully');


      } else {
        Fluttertoast.showToast(msg: 'Failed to Add Dangerous Spot');
      }
    } else {
      Fluttertoast.showToast(msg: 'Network Error');
    }
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

  String la="0";
  String lo="0";
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentPosition = position;
    setState(() {
       la= position.latitude.toString();
       lo= position.longitude.toString();
    });


  }
  late Timer _timer;
  Position? _currentPosition;
}
