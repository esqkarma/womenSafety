import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class Verify_dangerous_spot extends StatefulWidget {
  const Verify_dangerous_spot({super.key, required this.title});

  final String title;

  @override
  State<Verify_dangerous_spot> createState() => _Verify_dangerous_spotState();
}

class _Verify_dangerous_spotState extends State<Verify_dangerous_spot> {
  _Verify_dangerous_spotState() {
    getdata();
  }

  List<String> id_ = [];
  List<String> place_ = [];
  List<String> date_ = [];
  List<String> latitude_ = [];
  List<String> longitude_ = [];
  List<String> status_ = [];
  List<String> username_ = [];
  List<String> useremail_ = [];
  List<String> userphone_ = [];
  List<String> photo_ = [];

  Future<void> getdata() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      String lid = sh.getString('lid').toString();
      String url = '$urls/myapp/view_dangerous_spot_verify/';

      var data = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsondata = json.decode(data.body);

      List<dynamic> arr = jsondata['data'];
      setState(() {
        id_ = arr.map((item) => item['id'].toString()).toList();
        place_ = arr.map((item) => item['place'].toString()).toList();
        date_ = arr.map((item) => item['date'].toString()).toList();
        latitude_ = arr.map((item) => item['latitude'].toString()).toList();
        longitude_ = arr.map((item) => item['longitude'].toString()).toList();
        status_ = arr.map((item) => item['status'].toString()).toList();
        username_ = arr.map((item) => item['username'].toString()).toList();
        useremail_ = arr.map((item) => item['useremail'].toString()).toList();
        userphone_ = arr.map((item) => item['userphone'].toString()).toList();
        photo_ = arr.map((item) => urls + item['photo'].toString()).toList();
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: id_.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        photo_[index],
                        fit: BoxFit.cover,
                        height: 150,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Username', username_[index]),
                    _buildDetailRow('Email', useremail_[index]),
                    _buildDetailRow('Phone', userphone_[index]),
                    _buildDetailRow('Date', date_[index]),
                    _buildDetailRow('Status', status_[index]),
                    _buildDetailRow('Place', place_[index]),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton('Accept', Colors.green, () => handleAction(index, 'accept')),
                        _buildActionButton('Reject', Colors.red, () => handleAction(index, 'reject')),
                        _buildActionButton('Locate', Colors.blue, () => locateSpot(index)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: onPressed,
      child: Text(text,style: TextStyle(color: Colors.white),),
    );
  }

  void handleAction(int index, String action) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url').toString();
      String endpoint = action == 'accept' ? 'verify_dangerous_spot' : 'reject_dangerous_spot_pink';
      var response = await http.post(Uri.parse('$url/myapp/$endpoint/'), body: {'id': id_[index]});
      if (response.statusCode == 200 && jsonDecode(response.body)['status'] == 'ok') {
        getdata();
        Fluttertoast.showToast(msg: '${action.capitalize()}ed Successfully');
      } else {
        Fluttertoast.showToast(msg: 'Action Failed');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void locateSpot(int index) async {
    if (!await launchUrl(Uri.parse("https://maps.google.com/?q=${latitude_[index]},${longitude_[index]}"))) {
      throw Exception('Could not launch');
    }
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
