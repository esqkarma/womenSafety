import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shecare/user/chat.dart';
import 'package:shecare/user/home_screen.dart';


class Search_nearby_users extends StatefulWidget {
  const Search_nearby_users({super.key, required this.title});
  final String title;

  @override
  State<Search_nearby_users> createState() => _Search_nearby_usersState();
}

class _Search_nearby_usersState extends State<Search_nearby_users> {
  List<String> id_ = [];
  List<String> name_ = [];
  List<String> gender_ = [];
  List<String> phone_ = [];
  List<String> email_ = [];
  List<String> place_ = [];
  List<String> post_ = [];
  List<String> district_ = [];
  List<String> state_ = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData("");
  }

  Future<void> fetchData(String value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String urls = prefs.getString('url') ?? '';
      String lid = prefs.getString('lid') ?? '';
      String url = '$urls/myapp/search_nearby_users/';

      var response = await http.post(Uri.parse(url), body: {
        'lid': lid,
        'search': value,
      });
      var jsonData = json.decode(response.body);
      var data = jsonData["data"];

      setState(() {
        id_ = [];
        name_ = [];
        gender_ = [];
        phone_ = [];
        email_ = [];
        place_ = [];
        post_ = [];
        district_ = [];
        state_ = [];

        for (var user in data) {
          id_.add(user['id'].toString());
          name_.add(user['name'].toString());
          gender_.add(user['gender'].toString());
          phone_.add(user['phone'].toString());
          email_.add(user['email'].toString());
          place_.add(user['place'].toString());
          post_.add(user['post'].toString());
          district_.add(user['district'].toString());
          state_.add(user['state'].toString());
        }
      });
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE3EC),
        elevation: 1,
        title: const Text('Nearby Users'),
        leading: IconButton(onPressed: (){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx)=>UserHome()));
        }, icon: const Icon(Icons.arrow_back,color: Colors.black,)),
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
                // AppBar replacement




                // User list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: id_.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple,
                            child: Text(
                              name_[index][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(name_[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Gender: ${gender_[index]}"),
                              Text("Phone: ${phone_[index]}"),
                              Text("Email: ${email_[index]}"),
                              Text("Location: ${place_[index]}, ${district_[index]}, ${state_[index]}"),
                            ],
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[100],
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setString("toid", id_[index]);
                              prefs.setString("name", name_[index]);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyChatPage(title: 'Chat'),
                                ),
                              );
                            },
                            child: const Text("Chat"),
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
    );
  }

  // Drawer copied from UserHome for consistency
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
                  child: Icon(Icons.person_rounded, size: 40, color: Color(0xFFFF8FB1)),
                ),
                SizedBox(height: 12),
                Text("SheCare User", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Stay Safe, Stay Connected", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          // Menu items
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
