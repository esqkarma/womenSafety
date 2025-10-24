import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
      title: 'Add Dangerous Spot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const User_Add_dangerous_spot(title: 'Add Dangerous Spot'),
    );
  }
}

class User_Add_dangerous_spot extends StatefulWidget {
  const User_Add_dangerous_spot({super.key, required this.title});

  final String title;

  @override
  State<User_Add_dangerous_spot> createState() => _User_Add_dangerous_spotState();
}

class _User_Add_dangerous_spotState extends State<User_Add_dangerous_spot> {
  TextEditingController placeController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  File? _selectedImage;
  String photo = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Image Selection Section
            Center(
              child: InkWell(
                onTap: _checkPermissionAndChooseImage,
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                )
                    : Column(
                  children: [
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/128/846/846799.png',
                      height: 200,
                      width: 200,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap to select image',
                      style: TextStyle(color: Colors.cyan),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Place Field
            _buildTextField(placeController, 'Place'),

            // Latitude Field
            _buildTextField(latitudeController, 'Latitude'),

            // Longitude Field
            _buildTextField(longitudeController, 'Longitude'),

            // Add Button
            Center(
              child: ElevatedButton(
                onPressed: _sendData,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Add Dangerous Spot",
                  style: TextStyle(fontSize: 16,color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable TextField Widget
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // Image Upload Logic
  Future<void> _chooseAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        photo = base64Encode(_selectedImage!.readAsBytesSync());
      });
    }
  }

  Future<void> _checkPermissionAndChooseImage() async {
    final PermissionStatus status = await Permission.mediaLibrary.request();
    if (status.isGranted) {
      _chooseAndUploadImage();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
            'Please go to app settings and grant permission to choose an image.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Data Sending Logic
  Future<void> _sendData() async {
    String place = placeController.text.trim();
    String latitude = latitudeController.text.trim();
    String longitude = longitudeController.text.trim();

    if (place.isEmpty || latitude.isEmpty || longitude.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all fields');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = prefs.getString('url') ?? '';
    String lid = prefs.getString('lid') ?? '';

    final response = await http.post(
      Uri.parse('$url/myapp/user_add_dangerous_spot/'),
      body: {
        'place': place,
        'latitude': latitude,
        'longitude': longitude,
        'lid': lid,
        'photo': photo,
      },
    );

    if (response.statusCode == 200) {
      String status = jsonDecode(response.body)['status'];
      if (status == 'ok') {
        Fluttertoast.showToast(msg: 'Dangerous Spot Added Successfully');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserHome()),
        );
      } else {
        Fluttertoast.showToast(msg: 'Failed to Add Dangerous Spot');
      }
    } else {
      Fluttertoast.showToast(msg: 'Network Error');
    }
  }
}
