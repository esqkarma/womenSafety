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
      home: const Record_voice_and_camera_using_voice_button(title: 'Flutter Demo Home Page'),
    );
  }
}

class Record_voice_and_camera_using_voice_button extends StatefulWidget {
  const Record_voice_and_camera_using_voice_button({super.key, required this.title});



  final String title;

  @override
  State<Record_voice_and_camera_using_voice_button> createState() => _Record_voice_and_camera_using_voice_buttonState();
}

class _Record_voice_and_camera_using_voice_buttonState extends State<Record_voice_and_camera_using_voice_button> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[


          ],
        ),
      ),

    );
  }
}
