import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('volume.channel');
  int counter = 0;

  @override
  void initState() {
    super.initState();
    listenVolumeButton();
  }

  void listenVolumeButton() {
    // Listen for counter updates from Android
    platform.setMethodCallHandler((call) async {
      if (call.method == 'updateCounter') {
        int newCounter = call.arguments; // counter value from Android
        setState(() {
          counter = newCounter; // update UI
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Counter: $counter',
            style: const TextStyle(color: Colors.white, fontSize: 36),
          ),
        ),
      ),
    );
  }
}
