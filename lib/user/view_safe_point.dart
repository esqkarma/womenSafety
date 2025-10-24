import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shecare/user/view_notification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:shecare/user/edit_dangerous_spot.dart';
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
      home: const view_safe_point(title: 'Flutter Demo Home Page'),
    );
  }
}

class view_safe_point extends StatefulWidget {
  const view_safe_point({super.key, required this.title});



  final String title;

  @override
  State<view_safe_point> createState() => _view_safe_pointState();
}

class _view_safe_pointState extends State<view_safe_point> {
  _view_safe_pointState(){
    getdata("");
  }

  List<String> place_ = <String>[];
  List<String> latitude_ = <String>[];
  List<String> longitude_ = <String>[];
  List<String> landmark_ = <String>[];


  Future<void> getdata(value) async {
    List<String> place = <String>[];
    List<String> latitude = <String>[];
    List<String> longitude = <String>[];
    List<String> landmark = <String>[];


    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      String lid = sh.getString('lid').toString();
      String url = '$urls/myapp/user_view_safepoint/';

      var data = await http.post(Uri.parse(url), body: {
        'lid':lid,
        'search':value,
      });
      var jsondata = json.decode(data.body);
      String statuss = jsondata['status'];

      var arr = jsondata["data"];

      print(arr.length);

      for (int i = 0; i < arr.length; i++) {
        place.add(arr[i]['place'].toString());
        latitude.add(arr[i]['latitude'].toString());
        longitude.add(arr[i]['longitude'].toString());
        landmark.add(arr[i]['landmark'].toString());

      }

      setState(() {
        place_ = place;
        latitude_ = latitude;
        longitude_ = longitude;
        landmark_ = landmark;

      });

      print(statuss);
    } catch (e) {
      print("Error ------------------- " + e.toString());
      //there is error during converting file image to base64 encoding.
    }
  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(),
        body:
        ListView.builder(
          itemCount: place_.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(

                child: Column(

                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Image(image: NetworkImage(photo_[index]),fit: BoxFit.cover,),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,

                        children: [
                          Text('Place'),
                          Text(place_[index])
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,

                        children: [
                          Text('Latitude'),
                          Text(latitude_[index])
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,

                        children: [
                          Text('Longitude'),
                          Text(longitude_[index])
                        ],
                      ),
                    ), Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,

                        children: [
                          Text('Landmark'),
                          Text(landmark_[index])
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,

                        children: [
                          // ElevatedButton(onPressed: () async {
                          // }, child: Text("Edit")),


                          ElevatedButton(onPressed: () async {
                            if (!await launchUrl(Uri.parse("https://maps.google.com/?q="+latitude_[index]+","+longitude_[index]+""))) {
                              throw Exception('Could not launch');
                            }
                          }, child: Text("Locate")),
                        ],
                      ),
                    ),




                  ],
                ),
              ),
            );
          },)

    );
  }
}
