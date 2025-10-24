import 'dart:convert';
import 'package:easy_search_bar/easy_search_bar.dart';
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
      title: 'Dangerous Spots',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const View_dangerous_spot(title: 'Dangerous Spots'),
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
  _View_dangerous_spotState() {
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
        'lid': lid,
        'search': value,
      });

      var jsondata = json.decode(data.body);
      String statuss = jsondata['status'];

      var arr = jsondata["data"];

      for (int i = 0; i < arr.length; i++) {
        id.add(arr[i]['id'].toString());
        place.add(arr[i]['place'].toString());
        date.add(arr[i]['date'].toString());
        latitude.add(arr[i]['latitude'].toString());
        longitude.add(arr[i]['longitude'].toString());
        status.add(arr[i]['status'].toString());
        photo.add(urls + arr[i]['photo']);
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
    } catch (e) {
      print("Error ------------------- " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EasySearchBar(
        title: const Text('View Dangerous Spots'),
        onSearch: (value) => getdata(value),
        suggestions: place_,
      ),
      body: ListView.builder(
        itemCount: id_.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: <Widget>[
                  // Image Section
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      photo_[index],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Date:'),
                            Text(date_[index]),
                          ],
                        ),
                        const Divider(),
                        // Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Status:'),
                            Text(status_[index]),
                          ],
                        ),
                        const Divider(),
                        // Place
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Place:'),
                            Text(place_[index]),
                          ],
                        ),
                        const Divider(),
                        // Locate Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              final String mapUrl =
                                  "https://maps.google.com/?q=" +
                                      latitude_[index] +
                                      "," +
                                      longitude_[index];
                              if (!await launchUrl(Uri.parse(mapUrl))) {
                                throw Exception('Could not launch map');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: const Text("Locate on Map"),
                          ),
                        ),
                      ],
                    ),
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
