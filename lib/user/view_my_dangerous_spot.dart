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
      home: const view_my_dangerous_spot(title: 'Flutter Demo Home Page'),
    );
  }
}

class view_my_dangerous_spot extends StatefulWidget {
  const view_my_dangerous_spot({super.key, required this.title});



  final String title;

  @override
  State<view_my_dangerous_spot> createState() => _view_my_dangerous_spotState();
}

class _view_my_dangerous_spotState extends State<view_my_dangerous_spot> {
  _view_my_dangerous_spotState(){
    getdata();
  }

  List<String> id_ = <String>[];
  List<String> place_ = <String>[];
  List<String> date_ = <String>[];
  List<String> latitude_ = <String>[];
  List<String> longitude_ = <String>[];
  List<String> status_ = <String>[];
  List<String> photo_ = <String>[];



  Future<void> getdata() async {
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
      String url = '$urls/myapp/view_my_dangerous_spot_verify/';

      var data = await http.post(Uri.parse(url), body: {
        'lid':lid
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
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
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
                         Navigator.push(context, MaterialPageRoute(builder: (context)=>edit_spot(title: '', place: place_[index], latitude: latitude_[index], longitude: longitude_[index], photo: photo_[index], id: id_[index],)));
                         SharedPreferences sh = await SharedPreferences.getInstance();
                         sh.setString("sid", id_[index]).toString();
                        }, child: Text("Edit")),
                        ElevatedButton(onPressed: () async {
                          SharedPreferences sh = await SharedPreferences.getInstance();
                          String url = sh.getString('url').toString();
                          String lid = sh.getString('lid').toString();

                          final urls = Uri.parse('$url/myapp/delete_dangerous_spot/');
                          try {
                            final response = await http.post(urls, body: {
                              'id':id_[index],



                            });
                            if (response.statusCode == 200) {
                              String status = jsonDecode(response.body)['status'];
                              if (status=='ok') {
                                getdata();
                                Fluttertoast.showToast(msg: 'Dangerous Spot Deleted Successfully');

                              }else {
                                Fluttertoast.showToast(msg: 'Not Found');
                              }
                            }
                            else {
                              Fluttertoast.showToast(msg: 'Network Error');
                            }
                          }
                          catch (e){
                            Fluttertoast.showToast(msg: e.toString());
                          }
                        }, child: Text("Delete")),



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
