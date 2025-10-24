// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'edit_profile.dart';
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
//       home: const View_and_edit_profile(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class View_and_edit_profile extends StatefulWidget {
//   const View_and_edit_profile({super.key, required this.title});
//
//
//
//   final String title;
//
//   @override
//   State<View_and_edit_profile> createState() => _View_and_edit_profileState();
// }
//
// class _View_and_edit_profileState extends State<View_and_edit_profile> {
//
//
//   _View_and_edit_profileState(){
//     _get_data();
//   }
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
//         child:SingleChildScrollView(child:Column(
//
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Padding(padding: EdgeInsets.all(8),
//             child: Image(image: NetworkImage(photo),height: 200,width: 200,),),
//
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//                 children: [
//                   Text('Name'),
//                   Text(name)
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//                 children: [
//                   Text('Dob'),
//                   Text(dob)
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//                 children: [
//                   Text('Gender'),
//                   Text(gender)
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//                 children: [
//                   Text('Phone'),
//                   Text(phone)
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//                 children: [
//                   Text('Email'),
//                   Text(email)
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//                 children: [
//                   Text('Place'),
//                   Text(place)
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Text('Post'),
//                   Text(post)
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//                 children: [
//                   Text('District'),
//                   Text(district)
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//                 children: [
//                   Text('State'),
//                   Text(state)
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//                 children: [
//                   Text('Identification mark'),
//                   Text(identification_mark)
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//                 children: [
//                   Text('Fathers Name'),
//                   Text(fathers_name)
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//                 children: [
//                   Text('Mothers Name'),
//                   Text(mothers_name)
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//                 children: [
//                   Text('Blood Group'),
//                   Text(blood_group)
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(
//                   builder: (context) => edit_profile(title: "Edit Profile"),));
//
//               }, child: Text("Edit"))
//             ),
//
//
//
//           ],
//         ),
//       ),
//
//     ));
//   }
//
//
//   String name="";
//   String dob="";
//   String gender="";
//   String phone="";
//   String email="";
//   String place="";
//   String post="";
//   String district="";
//   String state="";
//   String photo="";
//   String identification_mark="";
//   String fathers_name="";
//   String mothers_name="";
//   String blood_group="";
//   void _get_data() async{
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url').toString();
//     String lid = sh.getString('lid').toString();
//
//     final urls = Uri.parse('$url/myapp/user_view_profile/');
//     try {
//       final response = await http.post(urls, body: {
//         'lid':lid,
//
//
//       });
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         if (status=='ok') {
//           setState(() {
//             name = jsonDecode(response.body)['Name'].toString();
//             dob = jsonDecode(response.body)['Dob'].toString();
//             gender = jsonDecode(response.body)['Gender'].toString();
//             phone = jsonDecode(response.body)['Phone'].toString();
//             email = jsonDecode(response.body)['Email'].toString();
//             place = jsonDecode(response.body)['Place'].toString();
//             post = jsonDecode(response.body)['Post'].toString();
//             district = jsonDecode(response.body)['District'].toString();
//             state = jsonDecode(response.body)['State'].toString();
//             photo = url+jsonDecode(response.body)['Photo'].toString();
//             identification_mark = jsonDecode(response.body)['Identification Mark'].toString();
//             fathers_name = jsonDecode(response.body)['Fathers Name'].toString();
//             mothers_name = jsonDecode(response.body)['Mothers Name'].toString();
//             blood_group = jsonDecode(response.body)['Blood Group'].toString();
//           });
//
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
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const View_and_edit_profile(title: 'Profile Details'),
    );
  }
}

class View_and_edit_profile extends StatefulWidget {
  const View_and_edit_profile({super.key, required this.title});

  final String title;

  @override
  State<View_and_edit_profile> createState() => _View_and_edit_profileState();
}

class _View_and_edit_profileState extends State<View_and_edit_profile> {
  _View_and_edit_profileState() {
    _getData();
  }

  String name = "";
  String dob = "";
  String gender = "";
  String phone = "";
  String email = "";
  String place = "";
  String post = "";
  String district = "";
  String state = "";
  String photo = "";
  String identificationMark = "";
  String fathersName = "";
  String mothersName = "";
  String bloodGroup = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Profile Image and Details
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(photo),
              ),
            ),
            const SizedBox(height: 20),

            // Profile Card
            Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.person, 'Name', name),
                    const Divider(),
                    _buildInfoRow(Icons.calendar_today, 'Date of Birth', dob),
                    const Divider(),
                    _buildInfoRow(Icons.accessibility, 'Gender', gender),
                    const Divider(),
                    _buildInfoRow(Icons.phone, 'Phone', phone),
                    const Divider(),
                    _buildInfoRow(Icons.email, 'Email', email),
                  ],
                ),
              ),
            ),

            // Address Card
            Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.location_on, 'Place', place),
                    const Divider(),
                    _buildInfoRow(Icons.location_city, 'Post', post),
                    const Divider(),
                    _buildInfoRow(Icons.location_on, 'District', district),
                    const Divider(),
                    _buildInfoRow(Icons.location_on, 'State', state),
                  ],
                ),
              ),
            ),

            // Additional Information Card
            Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.confirmation_number, 'ID Mark', identificationMark),
                    const Divider(),
                    _buildInfoRow(Icons.family_restroom, 'Father\'s Name', fathersName),
                    const Divider(),
                    _buildInfoRow(Icons.family_restroom, 'Mother\'s Name', mothersName),
                    const Divider(),
                    _buildInfoRow(Icons.bloodtype, 'Blood Group', bloodGroup),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Edit Button (Floating Action Button)
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const edit_profile(title: "Edit Profile"),
                    ),
                  );
                },
                child: const Icon(Icons.edit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for displaying each info row
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            value.isNotEmpty ? value : 'Not Available',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Fetch user data
  void _getData() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/myapp/user_view_profile/');
    try {
      final response = await http.post(urls, body: {
        'lid': lid,
      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          setState(() {
            name = jsonDecode(response.body)['Name'].toString();
            dob = jsonDecode(response.body)['Dob'].toString();
            gender = jsonDecode(response.body)['Gender'].toString();
            phone = jsonDecode(response.body)['Phone'].toString();
            email = jsonDecode(response.body)['Email'].toString();
            place = jsonDecode(response.body)['Place'].toString();
            post = jsonDecode(response.body)['Post'].toString();
            district = jsonDecode(response.body)['District'].toString();
            state = jsonDecode(response.body)['State'].toString();
            photo = url + jsonDecode(response.body)['Photo'].toString();
            identificationMark = jsonDecode(response.body)['Identification Mark'].toString();
            fathersName = jsonDecode(response.body)['Fathers Name'].toString();
            mothersName = jsonDecode(response.body)['Mothers Name'].toString();
            bloodGroup = jsonDecode(response.body)['Blood Group'].toString();
          });
        } else {
          Fluttertoast.showToast(msg: 'Profile Not Found');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
