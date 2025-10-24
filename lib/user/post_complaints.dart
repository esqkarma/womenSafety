import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shecare/user/home_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SheCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Post_complaint(title: 'Post a Complaint'),
    );
  }
}

class Post_complaint extends StatefulWidget {
  const Post_complaint({super.key, required this.title});

  final String title;

  @override
  State<Post_complaint> createState() => _Post_complaintState();
}

class _Post_complaintState extends State<Post_complaint> {
  TextEditingController complaintController = TextEditingController();

  late Timer _timer;
  Position? _currentPosition;


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

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Please describe your complaint below:',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: complaintController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Complaint',
                hintText: 'Describe your complaint here...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: EdgeInsets.all(16),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _sendData();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Send Complaint",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendData() async {
    String complaint = complaintController.text.toString();

    if (complaint.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a complaint.');
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final Uri urls = Uri.parse('$url/myapp/user_post_complaint/');
    try {
      final response = await http.post(urls, body: {
        'complaint': complaint,
        'lid': lid,
        'la': _currentPosition?.latitude.toString(),
        'lo': _currentPosition?.longitude.toString(),
      });

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          Fluttertoast.showToast(msg: 'Complaint Posted');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserHome()),
          );
        } else {
          Fluttertoast.showToast(msg: 'Failed to post complaint');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    }
  }
}

class UserHomepage extends StatelessWidget {
  final String title;

  const UserHomepage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Welcome to the Home Page')),
    );
  }
}
