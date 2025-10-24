import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shecare/user/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shecare/user/post_complaints.dart';

class view_replies extends StatefulWidget {
  const view_replies({super.key, required this.title});
  final String title;

  @override
  State<view_replies> createState() => _view_repliesState();
}

class _view_repliesState extends State<view_replies> {
  _view_repliesState() {
    getData("");
  }

  List<String> id_ = <String>[];
  List<String> date_ = <String>[];
  List<String> complaint_ = <String>[];
  List<String> reply_ = <String>[];
  List<String> status_ = <String>[];
  List<String> officerName_ = <String>[];
  List<String> phone_ = <String>[];

  Future<void> getData(value) async {
    List<String> id = <String>[];
    List<String> date = <String>[];
    List<String> complaint = <String>[];
    List<String> reply = <String>[];
    List<String> status = <String>[];
    List<String> officerName = <String>[];
    List<String> phone = <String>[];

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      String lid = sh.getString('lid').toString();
      String url = '$urls/myapp/user_view_complaint/';

      var data = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsonData = json.decode(data.body);
      String statusCode = jsonData['status'];


      var arr = jsonData["data"];

      for (int i = 0; i < arr.length; i++) {
        id.add(arr[i]['id'].toString());
        date.add(arr[i]['date'].toString());
        complaint.add(arr[i]['complaint'].toString());
        reply.add(arr[i]['reply'].toString());
        status.add(arr[i]['status'].toString());
        officerName.add(arr[i]['officername'].toString());
        phone.add(arr[i]['phone'].toString());
      }

      setState(() {
        id_ = id;
        date_ = date;
        complaint_ = complaint;
        reply_ = reply;
        status_ = status;
        officerName_ = officerName;
        phone_ = phone;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching data: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Complaints"),
        leading: IconButton(onPressed: (){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx)=>const UserHome()));
        }, icon: const Icon(Icons.arrow_back)),
      ),
      body: id_.isEmpty
          ? const Center(child: Text("No complaints available"))
          : ListView.builder(
        itemCount: id_.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date: ${date_[index]}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(
                          'Status: ${status_[index]}',
                          style: TextStyle(
                              color: status_[index] == 'Resolved'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Complaint: ${complaint_[index]}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text('Reply: ${reply_[index]}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.blue),
                            const SizedBox(width: 5),
                            Text('Officer: ${officerName_[index]}'),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.blue),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () async {
                                final Uri launchUri = Uri(
                                    scheme: 'tel',
                                    path: phone_[index]);
                                if (await canLaunchUrl(launchUri)) {
                                  await launchUrl(launchUri);
                                }
                              },
                              child: Text(phone_[index],
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerRight,
                      // child: ElevatedButton(
                      //   onPressed: () {
                      //     // Navigate to edit page
                      //   },
                      //   child: Text("Edit Complaint"),
                      // ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Post_complaint(title: "Post Complaints"),
              ));
        },
        child: const Icon(Icons.plus_one),
      ),
    );
  }
}
