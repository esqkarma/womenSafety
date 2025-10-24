// import 'dart:async';
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shecare/PinkPolice/pinkpolice_home.dart';
// import 'package:shecare/hm/screens/main_screen.dart';
// import 'package:shecare/pinkhm/screens/home_screen.dart';
// import 'package:shecare/user/sign_up.dart';
// import 'package:shecare/user/user_home.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const Login(title: 'Settings'),
//     );
//   }
// }
//
// class Login extends StatefulWidget {
//   const Login({super.key, required this.title});
//
//
//
//   final String title;
//
//   @override
//   State<Login> createState() => _LoginState();
// }
//
// class _LoginState extends State<Login> {
//   TextEditingController unamecontroller=TextEditingController();
//   TextEditingController passcontroller=TextEditingController();
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//
//         title: Text(widget.title),
//       ),
//       body: Center(
//
//         child: Column(
//
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//
//
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: TextFormField(
//                 controller: unamecontroller,
//                 decoration: InputDecoration(labelText: 'Username',border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),),
//             ),
//
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: TextFormField(
//                 controller: passcontroller,
//                 decoration: InputDecoration(labelText: 'Password',border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),),
//             ),
//
//
//
//             ElevatedButton(onPressed: () {
//
//
//               _send_data();
//             }, child: Text("Login")),
//
//               ElevatedButton(onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(
//                   builder: (context) => MyMySignupPage(title: "Home"),));
//
//
//               }, child: Text("Signup")),
//
//
//
//           ],
//         ),
//       ),
//
//     );
//   }
//   void _send_data() async{
//
//     String username= unamecontroller.text.toString();
//     String password= passcontroller.text.toString();
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url').toString();
//
//     final urls = Uri.parse('$url/myapp/pinkpolice_login/');
//     try {
//       final response = await http.post(urls, body: {
//         'username':username,
//         'password':password,
//
//
//       });
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         String type = jsonDecode(response.body)['type'].toString();
//         if (status=='ok') {
//
//           String lid=jsonDecode(response.body)['lid'].toString();
//           sh.setString("lid", lid);
//           if(type=='pinkpolice')
//             {
//               Navigator.push(context, MaterialPageRoute(
//                 builder: (context) => PinkPoliceHomeScreen(),));
//               Timer.periodic(Duration(seconds: 5),(timer) {
//                 updateLoc(lid);
//               },);
//
//             }
//           else if(type == "user"){
//             // Navigator.push(context, MaterialPageRoute(
//             //   builder: (context) => user_homepage(title: "Home"),));
//             //
//
//             Navigator.push(context, MaterialPageRoute(
//               builder: (context) => MainScreen(),));
//             Timer.periodic(Duration(seconds: 5),(timer) {
//               updateLoc(lid);
//             },);
//
//           }
//           else{
//             // Navigator.push(context, MaterialPageRoute(
//             //   builder: (context) => Pinkpolice_homepage(title: "Home"),));
//           }
//
//
//         }else {
//           Fluttertoast.showToast(msg: 'Not Found');
//         }
//       }
//       else {
//         Fluttertoast.showToast(msg: 'Network Error');
//       }
//     }
//     catch (e){
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }
//
//
//   void updateLoc(String lid) async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//
//     PermissionStatus status = await Permission.location.request();
//
//     if (status.isGranted) {
//       // If permission is granted, get the current position
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       String lat = position.latitude.toString();
//       String lon = position.longitude.toString();
//
//       sh.setString('lat', lat);
//       sh.setString('lon', lon);
//
//       print('Latitude: $lat, Longitude: $lon');
//     } else {
//       // Handle the case where permission is denied
//       print('Location permission de');
//     }
//     String url = sh.getString('url') ?? '';
//     final urls = Uri.parse('$url/myapp/updatelocation/');
//
//     try {
//       final response = await http.post(urls, body: {
//         'lid': lid,
//         'lat': sh.getString('lat'), // Add lat and lon here
//         'lon': sh.getString('lon'), // Make sure to provide these values
//       });
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         if (status != "ok") {
//           Fluttertoast.showToast(msg: "Location update failed");
//         }
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }
//
//
// }
