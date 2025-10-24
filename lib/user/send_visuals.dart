import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';




void main() {
  runApp(const MyMySignup());
}

class MyMySignup extends StatelessWidget {
  const MyMySignup({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySignup',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  CameraPage(),
    );
  }
}



class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final TextEditingController _textController = TextEditingController();
  File? _image;
  Position? _currentPosition;

  // Capture image using Camera
  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _getCurrentLocation();
    }
  }

  // Get current location coordinates
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
    });
  }

  // Send data to server
  Future<void> _sendDataToServer() async {
    if (_image == null || _currentPosition == null || _textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture image and fill text')),
      );
      return;
    }

    // Prepare data


    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/myapp/send_visuals/');


    var request = http.MultipartRequest('POST',urls);

    request.fields['text'] = _textController.text;
    request.fields['latitude'] = _currentPosition!.latitude.toString();
    request.fields['longitude'] = _currentPosition!.longitude.toString();
    request.fields['lid'] = sh.getString("lid").toString();



    print(_currentPosition!.latitude.toString()+"lkkkkkkkkkkkkkkkkkkkkkkkk");

    print(_currentPosition!.longitude.toString()+"lkkkkkkkkkkkkkkkkkkkkkkk");


    request.files.add(
      await http.MultipartFile.fromPath('photo', _image!.path),
    );
    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data sent successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send data!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture and Send Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter Text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _image != null
                ? Image.file(_image!, height: 150)
                : const Text('No image captured'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _captureImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _sendDataToServer,
              icon: const Icon(Icons.send),
              label: const Text('Send to Server'),
            ),
          ],
        ),
      ),
    );
  }
}
