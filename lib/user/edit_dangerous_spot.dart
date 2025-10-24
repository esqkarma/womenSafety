import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shecare/user/home_screen.dart';



class edit_spot extends StatefulWidget {
  const edit_spot({super.key, required this.title, required this.place, required this.latitude, required this.longitude, required this.photo, required this.id});



  final String title;
  final String place;
  final String latitude;
  final String longitude;
  final String photo;
  final String id;

  @override
  State<edit_spot> createState() => _edit_spotState();
}

class _edit_spotState extends State<edit_spot> {

  TextEditingController placecontroller=TextEditingController();
  TextEditingController latitudecontroller=TextEditingController();
  TextEditingController longitudecontroller=TextEditingController();
  a(){
    setState(() {
      placecontroller.text=widget.place;
      latitudecontroller.text=widget.latitude;
      longitudecontroller.text=widget.longitude;
      uphoto=widget.photo;

    });
  }

  @override
  void initState() {
    a();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.teal,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_selectedImage != null) ...{
              InkWell(
                child:
                Image.file(_selectedImage!, height: 400,),
                radius: 399,
                onTap: _checkPermissionAndChooseImage,
                // borderRadius: BorderRadius.all(Radius.circular(200)),
              ),
            } else ...{
              // Image(image: NetworkImage(),height: 100, width: 70,fit: BoxFit.cover,),
              InkWell(
                onTap: _checkPermissionAndChooseImage,
                child:Column(
                  children: [
                    Image(image: NetworkImage(uphoto),height: 200,width: 200,),
                    Text('Select Image',style: TextStyle(color: Colors.cyan))
                  ],
                ),
              ),
            },
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller:placecontroller ,
                decoration: InputDecoration(labelText: 'Place',border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: latitudecontroller,
                decoration: InputDecoration(labelText: 'Latitude',border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller:longitudecontroller ,
                decoration: InputDecoration(labelText: 'Longitude',border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),),
            ),
            ElevatedButton(onPressed: (){
              _send_data();
              // String pcontrol= placecontroller.text.toString();
              // String lacontrol= latitudecontroller.text.toString();
              // String locontrol= longitudecontroller.text.toString();




            }, child: Text("Update"))


          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  File? _selectedImage;
  String? _encodedImage;
  Future<void> _chooseAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        _encodedImage = base64Encode(_selectedImage!.readAsBytesSync());
        photo = _encodedImage.toString();
      });
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

  String photo = '';
  String uphoto = '';
  void _send_data() async{

    String pcontrol= placecontroller.text.toString();
    String lacontrol= latitudecontroller.text.toString();
    String locontrol= longitudecontroller.text.toString();

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();
    String sid = sh.getString('sid').toString();

    final urls = Uri.parse('$url/myapp/edit_dangerous_spot/');
    try {
      final response = await http.post(urls, body: {
        'place':pcontrol,
        'latitude':lacontrol,
        'longitude':locontrol,
        'lid':lid,
        'photo':photo,
        'sid':sid


      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status=='ok') {
          Fluttertoast.showToast(msg: 'Dangerous Spot Updated Successfully');

          Navigator.push(context, MaterialPageRoute(builder: (context)=>UserHome()));

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
  }
}
