import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shecare/user/home_screen.dart';

import 'package:shecare/user/share_ideas_and_image.dart';

class View_ideas_and_image extends StatefulWidget {
  const View_ideas_and_image({super.key, required this.title});
  final String title;

  @override
  State<View_ideas_and_image> createState() => _View_ideas_and_imageState();
}

class _View_ideas_and_imageState extends State<View_ideas_and_image> {
  List<String> id_ = [];
  List<String> date_ = [];
  List<String> idea_ = [];
  List<String> image_ = [];

  @override
  void initState() {
    super.initState();
    viewReply();
  }

  Future<void> viewReply() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String lid = sh.getString('lid') ?? '';
      String url = '$urls/myapp/user_view_idea/';

      var data = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsondata = json.decode(data.body);
      var arr = jsondata["data"];

      List<String> id = [];
      List<String> date = [];
      List<String> idea = [];
      List<String> image = [];

      for (var item in arr) {
        id.add(item['id'].toString());
        date.add(item['date'].toString());
        idea.add(item['idea']);
        image.add(urls + item['image']);
      }

      setState(() {
        id_ = id;
        date_ = date;
        idea_ = idea;
        image_ = image;
      });
    } catch (e) {
      print("Error: " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE3EC),
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => UserHome()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFE3EC),
                    Color(0xFFFFC2D6),
                    Color(0xFFFF8FB1),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Ideas list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: id_.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date: ${date_[index]}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Idea: ${idea_[index]}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  image_[index],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Share_ideas_and_image(title: "Share ideas"),
            ),
          );
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Drawer matching the modern theme
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8FB1), Color(0xFFFFC2D6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_rounded,
                      size: 40, color: Color(0xFFFF8FB1)),
                ),
                SizedBox(height: 12),
                Text("SheCare User",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Stay Safe, Stay Connected",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded, color: Colors.grey),
            title: const Text("Dashboard"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.contact_phone_rounded, color: Colors.grey),
            title: const Text("Emergency Contacts"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.people_rounded, color: Colors.grey),
            title: const Text("Nearby Users"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
