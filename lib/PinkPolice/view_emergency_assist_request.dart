// import 'package:shecare/Pinkpolice_homepage/';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shecare/PinkPolice/pinkpolice_home.dart';
import 'package:shecare/pinkhm/screens/main_screen.dart';
import 'package:url_launcher/url_launcher.dart';



class View_emergency_assist_request extends StatefulWidget {
  const View_emergency_assist_request({super.key, required this.title});

  final String title;

  @override
  State<View_emergency_assist_request> createState() => _View_emergency_assist_requestState();
}

class _View_emergency_assist_requestState extends State<View_emergency_assist_request> {

  _View_emergency_assist_requestState(){
    viewReply();
  }

  List<String> id_ = <String>[];
  List<String> date_= <String>[];
  List<String> name_= <String>[];
  List<String> request_= <String>[];
  List<String> latitude_= <String>[];
  List<String> longitude_= <String>[];

  Future<void> viewReply() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      String lid = sh.getString('lid').toString();
      String url = '$urls/myapp/emergency_request_view/';

      var data = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsondata = json.decode(data.body);
      String status = jsondata['status'];

      var arr = jsondata["data"];

      for (int i = 0; i < arr.length; i++) {
        id_.add(arr[i]['id'].toString());
        date_.add(arr[i]['date']);
        name_.add(arr[i]['name']);
        request_.add(arr[i]['request']);
        latitude_.add(arr[i]['latitude']);
        longitude_.add(arr[i]['longitude']);
      }

      setState(() {});
    } catch (e) {
      print("Error: " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PinkMainScreen()),
          );
        }),
        backgroundColor: Colors.teal,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: id_.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            margin: EdgeInsets.all(10),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${date_[index]}', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Name: ${name_[index]}'),
                  Text('Request: ${request_[index]}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () async {
                          try {
                            SharedPreferences sh = await SharedPreferences.getInstance();
                            String url = sh.getString('url').toString();
                            final response = await http.post(
                              Uri.parse('$url/myapp/update_assist/'),
                              body: {'id': id_[index]},
                            );

                            if (response.statusCode == 200 && jsonDecode(response.body)['status'] == 'ok') {
                              Fluttertoast.showToast(msg: 'Success');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => View_emergency_assist_request(title: 'View Emergency Assists',)),
                              );
                            } else {
                              Fluttertoast.showToast(msg: 'Not Found');
                            }
                          } catch (e) {
                            Fluttertoast.showToast(msg: e.toString());
                          }
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () => locateSpot(index),
                        child: Text('Locate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> updateAssist(int index) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url').toString();
      final response = await http.post(
        Uri.parse('$url/myapp/update_assist/'),
        body: {'id': id_[index]},
      );

      if (response.statusCode == 200 && jsonDecode(response.body)['status'] == 'ok') {
        Fluttertoast.showToast(msg: 'Success');
        viewReply();
      } else {
        Fluttertoast.showToast(msg: 'Not Found');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void locateSpot(int index) async {
    String url = "https://maps.google.com/?q=${latitude_[index]},${longitude_[index]}";
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
