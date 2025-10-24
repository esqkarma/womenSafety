import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Change_password (title: 'Flutter Demo Home Page'),
    );
  }
}

class Change_password extends StatefulWidget {
  const Change_password({super.key, required this.title});



  final String title;

  @override
  State<Change_password > createState() => _Change_passwordState();
}

class _Change_passwordState extends State<Change_password> {

  TextEditingController currentcontroller=TextEditingController();
  TextEditingController newcontroller=TextEditingController();
  TextEditingController confirmcontroller=TextEditingController();


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.teal,
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: currentcontroller,
                decoration: InputDecoration(labelText: 'Current Password',border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: newcontroller,
                decoration: InputDecoration(labelText: 'New Password',border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: confirmcontroller,
                decoration: InputDecoration(labelText: 'Confirm Password',border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),),
            ),
            ElevatedButton(onPressed: (){
            String oldcontrol= currentcontroller.text.toString();
            String newcontrol= newcontroller.text.toString();
            String confirmcontrol= confirmcontroller.text.toString();

            print("hello");
                        }, child: Text("submit"))



          ],
        ),
      ),

    );
  }
}
