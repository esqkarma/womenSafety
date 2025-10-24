import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';


class MotionDetector extends StatefulWidget {
  const MotionDetector({super.key});

  @override
  State<MotionDetector> createState() => _MotionDetectorState();
}

class _MotionDetectorState extends State<MotionDetector> {
  double x = 0, y = 0, z = 0;
  String motionStatus = "📱 Waiting for motion...";

  @override
  void initState() {
    super.initState();

    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
      });

      // Detect shake or strong movement
      double totalForce = sqrt(x * x + y * y + z * z);

      if (totalForce > 20) { // you can tweak this threshold
        setState(() {
          motionStatus = "🚨 Device Shaken!";
        });
      } else if (x.abs() > 5 || y.abs() > 5) {
        setState(() {
          motionStatus = "📲 Device Tilted!";
        });
      } else {
        setState(() {
          motionStatus = "✅ Stable";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Motion Detection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              motionStatus,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Text('X: ${x.toStringAsFixed(2)}'),
            Text('Y: ${y.toStringAsFixed(2)}'),
            Text('Z: ${z.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
