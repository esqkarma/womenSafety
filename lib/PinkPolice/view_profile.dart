import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';



class View_profile extends StatefulWidget {
  const View_profile({super.key, required this.title});

  final String title;

  @override
  State<View_profile> createState() => _View_profileState();
}

class _View_profileState extends State<View_profile> {
  _View_profileState() {
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildInfoTile('Vehicle No', vechileno),
                  _buildInfoTile('Officer Name', officername),
                  _buildInfoTile('Place', place),
                  _buildInfoTile('Post', post),
                  _buildInfoTile('District', district),
                  _buildInfoTile('State', state),
                  _buildInfoTile('Email', email),
                  _buildInfoTile('Phone', phone),
                  _buildInfoTile('Gender', gender),
                  _buildInfoTile('DOB', dob),
                  _buildInfoTile('Station Name', station_name),
                  _buildInfoTile('Station Email', station_email),
                  _buildInfoTile('Station Phone', station_phone),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  String vechileno = "";
  String officername = "";
  String place = "";
  String post = "";
  String district = "";
  String state = "";
  String email = "";
  String phone = "";
  String gender = "";
  String dob = "";
  String station_name = "";
  String station_email = "";
  String station_phone = "";

  void _getData() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/myapp/pinkpolice_view_profile/');
    try {
      final response = await http.post(urls, body: {'lid': lid});
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          setState(() {
            vechileno = jsonDecode(response.body)['vechileno'].toString();
            officername = jsonDecode(response.body)['officername'].toString();
            place = jsonDecode(response.body)['place'].toString();
            post = jsonDecode(response.body)['post'].toString();
            district = jsonDecode(response.body)['district'].toString();
            state = jsonDecode(response.body)['state'].toString();
            email = jsonDecode(response.body)['email'].toString();
            phone = jsonDecode(response.body)['phone'].toString();
            gender = jsonDecode(response.body)['gender'].toString();
            dob = jsonDecode(response.body)['dob'].toString();
            station_name = jsonDecode(response.body)['station_name'].toString();
            station_email = jsonDecode(response.body)['station_email'].toString();
            station_phone = jsonDecode(response.body)['station_phone'].toString();
          });
        } else {
          Fluttertoast.showToast(msg: 'Not Found');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
