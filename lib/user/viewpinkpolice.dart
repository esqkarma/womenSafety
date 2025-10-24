import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // Importing url_launcher

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const View_pink_police(title: 'Flutter Demo Home Page'),
    );
  }
}

class View_pink_police extends StatefulWidget {
  const View_pink_police({super.key, required this.title});

  final String title;

  @override
  State<View_pink_police> createState() => _View_pink_policeState();
}

class _View_pink_policeState extends State<View_pink_police> {
  _View_pink_policeState() {
    getdata("");
  }

  List<String> id_ = <String>[];
  List<String> name_ = <String>[];
  List<String> phone_ = <String>[];

  // Function to get data from the API
  Future<void> getdata(value) async {
    List<String> id = <String>[];
    List<String> name = <String>[];
    List<String> phone = <String>[];

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      String lid = sh.getString('lid').toString();
      String url = '$urls/myapp/View_pink_police/';

      var data = await http.post(Uri.parse(url), body: {
        'lid': lid,
      });
      var jsondata = json.decode(data.body);
      String statuss = jsondata['status'];

      var arr = jsondata["data"];

      print(arr.length);

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

      print(statuss);
    } catch (e) {
      print("Error ------------------- " + e.toString());
    }
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: id_.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(name_[index]), // Display the name (optional)
                  Text(phone_[index]), // Display the phone number (optional)
                  ElevatedButton(
                    onPressed: () async {
                      _makeEmergencyCall(phone_[index]);
                    },
                    child: Text("Emergency Call"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
