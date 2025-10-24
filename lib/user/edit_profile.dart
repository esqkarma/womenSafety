//
//
// import 'dart:io';
//
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart ';
//
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shecare/Nlogin.dart';
// import 'package:shecare/user/view_and_edit_profile.dart';
// // import 'Nlogin.dart';
//
//
// void main() {
//   runApp(const MyMySignup());
// }
//
// class MyMySignup extends StatelessWidget {
//   const MyMySignup({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MySignup',
//       theme: ThemeData(
//
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const edit_profile(title: 'MySignup'),
//     );
//   }
// }
//
// class edit_profile extends StatefulWidget {
//   const edit_profile({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<edit_profile> createState() => _edit_profileState();
// }
//
// class _edit_profileState extends State<edit_profile> {
//
//   String gender = "Male";
//   String img = "";
//   File? uploadimage;
//   TextEditingController nameController= new TextEditingController();
//   TextEditingController dobController= new TextEditingController();
//   TextEditingController genderController= new TextEditingController();
//   TextEditingController phoneController= new TextEditingController();
//   TextEditingController emailController= new TextEditingController();
//   TextEditingController placeController= new TextEditingController();
//   TextEditingController postController= new TextEditingController();
//   TextEditingController districtController= new TextEditingController();
//   TextEditingController stateController= new TextEditingController();
//   TextEditingController idmarkController= new TextEditingController();
//   TextEditingController fnameController= new TextEditingController();
//   TextEditingController mnameController= new TextEditingController();
//   TextEditingController bloodgroupController= new TextEditingController();
//
//
//
// _edit_profileState(){
//   _get_data();
// }
//
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
//             nameController.text = jsonDecode(response.body)['Name'].toString();
//             dobController.text = jsonDecode(response.body)['Dob'].toString();
//             genderController.text = jsonDecode(response.body)['Gender'].toString();
//             phoneController.text = jsonDecode(response.body)['Phone'].toString();
//             emailController.text = jsonDecode(response.body)['Email'].toString();
//             placeController.text = jsonDecode(response.body)['Place'].toString();
//             postController.text = jsonDecode(response.body)['Post'].toString();
//             districtController.text = jsonDecode(response.body)['District'].toString();
//             stateController.text = jsonDecode(response.body)['State'].toString();
//             img = url+jsonDecode(response.body)['Photo'].toString();
//             idmarkController.text = jsonDecode(response.body)['Identification Mark'].toString();
//             fnameController.text = jsonDecode(response.body)['Fathers Name'].toString();
//             mnameController.text = jsonDecode(response.body)['Mothers Name'].toString();
//             bloodgroupController.text = jsonDecode(response.body)['Blood Group'].toString();
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
//
//   // Future<void> chooseImage() async {
//   //   // final choosedimage = await ImagePicker().pickImage(source: ImageSource.gallery);
//   //   //set source: ImageSource.camera to get image from camera
//   //   setState(() {
//   //     // uploadimage = File(choosedimage!.path);
//   //   });
//   // }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return WillPopScope(
//       onWillPop: () async{ return true; },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//           title: Text(widget.title),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               if (_selectedImage != null) ...{
//                 InkWell(
//                   child:
//                   Image.file(_selectedImage!, height: 400,),
//                   radius: 399,
//                   onTap: _checkPermissionAndChooseImage,
//                   // borderRadius: BorderRadius.all(Radius.circular(200)),
//                 ),
//               } else ...{
//                 // Image(image: NetworkImage(),height: 100, width: 70,fit: BoxFit.cover,),
//                 InkWell(
//                   onTap: _checkPermissionAndChooseImage,
//                   child:Column(
//                     children: [
//                       Image(image: NetworkImage(img),height: 200,width: 200,),
//                       Text('Select Image',style: TextStyle(color: Colors.cyan))
//                     ],
//                   ),
//                 ),
//               },
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: TextField(
//                   controller: nameController,
//                   decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Name")),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: TextField(
//                   controller: dobController,
//                   decoration: InputDecoration(border: OutlineInputBorder(),label: Text("DoB")),
//                 ),
//               ),
//               RadioListTile(value: "Male", groupValue: gender, onChanged: (value) { setState(() {gender="Male";}); },title: Text("Male"),),
//               RadioListTile(value: "Female", groupValue: gender, onChanged: (value) { setState(() {gender="Female";}); },title: Text("Female"),),
//               RadioListTile(value: "Other", groupValue: gender, onChanged: (value) { setState(() {gender="Other";}); },title: Text("Other"),),
//
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: TextField(
//                   controller: phoneController ,
//
//                   decoration: InputDecoration(border: OutlineInputBorder(),label: Text("+91")),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: TextField(
//                   controller: emailController ,
//
//                   decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Email")),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: TextField(
//                   controller: placeController,
//
//                   decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Place")),
//                 ),
//               ),   Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: TextField(
//                   controller: postController,
//
//                   decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Post")),
//                 ),
//               ),
//
//
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: TextField(
//                   controller: districtController,
//
//                   decoration: InputDecoration(border: OutlineInputBorder(),label: Text("District")),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: TextField(
//                   controller: stateController,
//
//                   decoration: InputDecoration(border: OutlineInputBorder(),label: Text("State")),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: TextField(
//                   controller: idmarkController,
//
//                   decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Identification Mark")),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: TextField(
//                   controller: fnameController,
//
//                   decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Father's Name")),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: TextField(
//                   controller: mnameController,
//
//                   decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Mother's Name")),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: TextField(
//                   controller: bloodgroupController,
//
//                   decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Blood Group")),
//                 ),
//               ),
//
//
//               ElevatedButton(
//                 onPressed: () {
//
//                   _send_data() ;
//
//                 },
//                 child: Text("Update"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//   void _send_data() async{
//
//     String uname=nameController.text;
//     String dob=dobController.text;
//     String gender=genderController.text;
//     String phone=phoneController.text;
//     String email=emailController.text;
//     String place=placeController.text;
//     String post=postController.text;
//     String district=districtController.text;
//     String state=stateController.text;
//     String idmark=idmarkController.text;
//     String fname=fnameController.text;
//     String mname=mnameController.text;
//     String bloodgroup=bloodgroupController.text;
//
//
//
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url').toString();
//     String lid = sh.getString('lid').toString();
//
//     final urls = Uri.parse('$url/myapp/user_edit_profile/');
//     try {
//
//       final response = await http.post(urls, body: {
//         "photo":photo,
//         "name":uname,
//         "dob":dob,
//         "gender":gender,
//         "phone":phone,
//         "email":email,
//         "place":place,
//         "post":post,
//         "district":district,
//         "state":state,
//         "identification_mark":idmark,
//         "fathers_name":fname,
//         "mothers_name":mname,
//         "blood_group":bloodgroup,
//         'lid':lid
//
//
//
//
//       });
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         if (status=='ok') {
//
//           Fluttertoast.showToast(msg: 'Update Successfull');
//           Navigator.push(context, MaterialPageRoute(
//             builder: (context) => View_and_edit_profile(title: "Profile"),));
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
//   File? _selectedImage;
//   String? _encodedImage;
//   Future<void> _chooseAndUploadImage() async {
//     final picker = ImagePicker();
//     final pickedImage = await picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedImage != null) {
//       setState(() {
//         _selectedImage = File(pickedImage.path);
//         _encodedImage = base64Encode(_selectedImage!.readAsBytesSync());
//         photo = _encodedImage.toString();
//       });
//     }
//   }
//
//   Future<void> _checkPermissionAndChooseImage() async {
//     final PermissionStatus status = await Permission.mediaLibrary.request();
//     if (status.isGranted) {
//       _chooseAndUploadImage();
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) => AlertDialog(
//           title: const Text('Permission Denied'),
//           content: const Text(
//             'Please go to app settings and grant permission to choose an image.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   String photo = '';
//
// }
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'view_and_edit_profile.dart';  // Make sure you have this file

void main() {
  runApp(const MySignup());
}

class MySignup extends StatelessWidget {
  const MySignup({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Edit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const edit_profile(title: 'Edit Profile'),
    );
  }
}

class edit_profile extends StatefulWidget {
  const edit_profile({super.key, required this.title});

  final String title;

  @override
  State<edit_profile> createState() => _edit_profileState();
}

class _edit_profileState extends State<edit_profile> {
  String gender = "Male";
  String img = "";
  File? _selectedImage;
  String photo = '';

  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController postController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController idmarkController = TextEditingController();
  TextEditingController fnameController = TextEditingController();
  TextEditingController mnameController = TextEditingController();
  TextEditingController bloodgroupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/myapp/user_view_profile/');
    try {
      final response = await http.post(urls, body: {'lid': lid});
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          setState(() {
            nameController.text = jsonDecode(response.body)['Name'].toString();
            dobController.text = jsonDecode(response.body)['Dob'].toString();
            phoneController.text = jsonDecode(response.body)['Phone'].toString();
            emailController.text = jsonDecode(response.body)['Email'].toString();
            placeController.text = jsonDecode(response.body)['Place'].toString();
            postController.text = jsonDecode(response.body)['Post'].toString();
            districtController.text = jsonDecode(response.body)['District'].toString();
            stateController.text = jsonDecode(response.body)['State'].toString();
            img = url + jsonDecode(response.body)['Photo'].toString();
            idmarkController.text = jsonDecode(response.body)['Identification Mark'].toString();
            fnameController.text = jsonDecode(response.body)['Fathers Name'].toString();
            mnameController.text = jsonDecode(response.body)['Mothers Name'].toString();
            bloodgroupController.text = jsonDecode(response.body)['Blood Group'].toString();
          });
        } else {
          Fluttertoast.showToast(msg: 'Not Found');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> _checkPermissionAndChooseImage() async {
    final PermissionStatus status = await Permission.mediaLibrary.request();
    if (status.isGranted) {
      _chooseAndUploadImage();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
            'Please go to app settings and grant permission to choose an image.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _chooseAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        photo = base64Encode(_selectedImage!.readAsBytesSync());
      });
    }
  }

  void _sendData() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/myapp/user_edit_profile/');
    try {
      final response = await http.post(urls, body: {
        "photo": photo,
        "name": nameController.text,
        "dob": dobController.text,
        "gender": gender,
        "phone": phoneController.text,
        "email": emailController.text,
        "place": placeController.text,
        "post": postController.text,
        "district": districtController.text,
        "state": stateController.text,
        "identification_mark": idmarkController.text,
        "fathers_name": fnameController.text,
        "mothers_name": mnameController.text,
        "blood_group": bloodgroupController.text,
        'lid': lid
      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          Fluttertoast.showToast(msg: 'Update Successful');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const View_and_edit_profile(title: 'Profile')),
          );
        } else {
          Fluttertoast.showToast(msg: 'Update Failed');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        dobController.text = '${picked.toLocal()}'.split(' ')[0]; // formatted date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Section
            Center(
              child: InkWell(
                onTap: _checkPermissionAndChooseImage,
                child: _selectedImage == null
                    ? Column(
                  children: [
                    Image.network(img, height: 150, width: 150, fit: BoxFit.cover),
                    const SizedBox(height: 10),
                    const Text('Tap to select image', style: TextStyle(color: Colors.blue)),
                  ],
                )
                    : Image.file(_selectedImage!, height: 150, width: 150, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),

            // Editable Fields
            _buildTextField(nameController, 'Name'),
            _buildDateOfBirthField(dobController, 'Date of Birth'),
            _buildRadioButton('Male'),
            _buildRadioButton('Female'),
            _buildRadioButton('Other'),
            _buildTextField(phoneController, 'Phone'),
            _buildTextField(emailController, 'Email'),
            _buildTextField(placeController, 'Place'),
            _buildTextField(postController, 'Post'),
            _buildTextField(districtController, 'District'),
            _buildTextField(stateController, 'State'),
            _buildTextField(idmarkController, 'Identification Mark'),
            _buildTextField(fnameController, 'Father\'s Name'),
            _buildTextField(mnameController, 'Mother\'s Name'),
            _buildTextField(bloodgroupController, 'Blood Group'),

            const SizedBox(height: 20),

            // Update Button
            Center(
              child: ElevatedButton(
                onPressed: _sendData,
                child: const Text('Update Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }

  Widget _buildDateOfBirthField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => _selectDateOfBirth(context),
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: label,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioButton(String value) {
    return RadioListTile<String>(
      value: value,
      groupValue: gender,
      onChanged: (value) {
        setState(() {
          gender = value!;
        });
      },
      title: Text(value),
    );
  }
}
