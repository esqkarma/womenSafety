import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shecare/Nlogin.dart';
import 'package:shecare/login.dart';
import 'package:shecare/pinkhm/screens/login_screen.dart';


class MyChangePasswordPage extends StatefulWidget {
  const MyChangePasswordPage({super.key, required this.title});

  final String title;

  @override
  State<MyChangePasswordPage> createState() => _MyChangePasswordPageState();
}

class _MyChangePasswordPageState extends State<MyChangePasswordPage> {
  TextEditingController oldpasswordController= new TextEditingController();
  TextEditingController newpasswordController= new TextEditingController();
  TextEditingController confirmpasswordController= new TextEditingController();


  @override
  Widget build(BuildContext context) {



    return WillPopScope(
      onWillPop: () async{ return true; },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[



              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: oldpasswordController,
                  decoration: InputDecoration(labelText: 'Current Password',border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: newpasswordController,
                  decoration: InputDecoration(labelText: 'New Password',border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: confirmpasswordController,
                  decoration: InputDecoration(labelText: 'Confirm Password',border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8),
              //   child: TextField(
              //     controller: oldpasswordController,
              //
              //     decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Old Password")),
              //   ),
              // ),
              // Padding(
              //
              //   padding: const EdgeInsets.all(8),
              //   child: TextField(
              //
              //     controller:newpasswordController,
              //     decoration: InputDecoration(border: OutlineInputBorder(),label: Text("New Password")),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(8),
              //   child: TextField(
              //     controller: confirmpasswordController,
              //
              //     decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Confirm Password")),
              //   ),
              // ),

              ElevatedButton(
                onPressed: (){

                 _send_data();
                },
                child: Text("ChangePassword"),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _send_data() async{

    String oldp= oldpasswordController.text;
    String newp= newpasswordController.text;
    String confirmp= confirmpasswordController.text;


    print(oldp);



    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/myapp/pink_change_password/');
    try {
      final response = await http.post(urls, body: {
        'lid':lid,
        'old_password':oldp,
        'new_password':newp,
        'confirm_password':confirmp,
      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status=='ok') {
          Fluttertoast.showToast(msg: 'Password Changed Successfully');
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()));
        }else {
          Fluttertoast.showToast(msg: 'Incorrect Password');
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
