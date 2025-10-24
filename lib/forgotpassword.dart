import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shecare/PinkPolice/pinkpolice_home.dart';

import 'package:shecare/login.dart';
import 'package:shecare/pinkhm/screens/main_screen.dart';
import 'package:shecare/user/sign_up.dart';

void main() {
  runApp(SheCareApp());
}

class SheCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SheCare App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Forgot_Password(),
    );
  }
}

class Forgot_Password extends StatefulWidget {
  @override
  _Forgot_PasswordState createState() => _Forgot_PasswordState();
}

class _Forgot_PasswordState extends State<Forgot_Password> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController unamecontroller = TextEditingController();
  final TextEditingController passcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/pink.jpg', // Your background image
              fit: BoxFit.cover,
            ),
          ),
          // Overlay for text readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Transparent overlay
            ),
          ),
          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top empty space or logo (optional)
              Container(
                height: 350, // Adjust if you need more space at the top
              ),

              // Form and login button at the bottom
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        // Email Input
                        TextFormField(
                          controller: unamecontroller,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email, color: Colors.blue),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),

                        // Password Input

                        // Login Button
                        ElevatedButton(
                          onPressed: () {
                            // if (_formKey.currentState?.validate() ?? false) {

                            _send_data();
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(content: Text('Logging in...')),
                            // );
                            // }
                          },
                          child: Text('Send'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Forgot Password Link

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _send_data() async{

    String username= unamecontroller.text.toString();
    String password= passcontroller.text.toString();

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();

    final urls = Uri.parse('$url/myapp/send_mail_page/');
    try {
      final response = await http.post(urls, body: {
        'email':username,


      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status=='ok') {

          Navigator.push(context, MaterialPageRoute(
            builder: (context) => LoginPage(),));

        }
        else if(status=="no"){
          Fluttertoast.showToast(msg: 'Email doe');

        }
        else {
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
  }




}
