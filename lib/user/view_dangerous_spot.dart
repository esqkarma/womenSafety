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
      home: const View_dangerous_spot(title: 'Flutter Demo Home Page'),
    );
  }
}

class View_dangerous_spot extends StatefulWidget {
  const View_dangerous_spot({super.key, required this.title});



  final String title;

  @override
  State<View_dangerous_spot> createState() => _View_dangerous_spotState();
}

class _View_dangerous_spotState extends State<View_dangerous_spot> {
  _View_dangerous_spotState(){
    getdata("");
  }

  List<String> id_ = <String>[];
  List<String> place_ = <String>[];
  List<String> date_ = <String>[];
  List<String> latitude_ = <String>[];
  List<String> longitude_ = <String>[];
  List<String> status_ = <String>[];
  List<String> photo_ = <String>[];



  Future<void> getdata(value) async {
    List<String> id = <String>[];
    List<String> place = <String>[];
    List<String> date = <String>[];
    List<String> latitude = <String>[];
    List<String> longitude = <String>[];
    List<String> status = <String>[];
    List<String> photo = <String>[];


    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      String lid = sh.getString('lid').toString();
      String url = '$urls/myapp/view_dangerous_spot/';

      var data = await http.post(Uri.parse(url), body: {
        'lid':lid,
        'search':value,
      });
      var jsondata = json.decode(data.body);
      String statuss = jsondata['status'];

      var arr = jsondata["data"];

      print(arr.length);

      for (int i = 0; i < arr.length; i++) {
        id.add(arr[i]['id'].toString());
        place.add(arr[i]['place'].toString());
        date.add(arr[i]['date'].toString());
        latitude.add(arr[i]['latitude'].toString());
        longitude.add(arr[i]['longitude'].toString());
        status.add(arr[i]['status'].toString());
        photo.add(urls+ arr[i]['photo']);

      }

      setState(() {
        id_ = id;
        place_ = place;
        date_ = date;
        latitude_ = latitude;
        longitude_ = longitude;
        status_ = status;
        photo_ = photo;

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
        itemCount: id_.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(

              child: Column(

                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(image: NetworkImage(photo_[index]),fit: BoxFit.cover,),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,

                      children: [
                        Text('date'),
                        Text(date_[index])
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,

                      children: [
                        Text('status'),
                        Text(status_[index])
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,

                      children: [
                        Text('place'),
                        Text(place_[index])
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
