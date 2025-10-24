import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('volume.channel');
  final Telephony telephony = Telephony.instance;

  String locationText = "Fetching location...";
  String latitude = "0.0", longitude = "0.0";
  String status = "";
  int smsAttemptCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await getLocation();
    platform.setMethodCallHandler(handleNativeCall);
  }

  Future<void> handleNativeCall(MethodCall call) async {
    if (call.method == "volumeButtonPressed") {
      if (smsAttemptCount == 0) {
        smsAttemptCount++;
        await sendLocationSms();
        Future.delayed(const Duration(seconds: 5), () {
          smsAttemptCount = 0;
        });
      }
    }
  }

  Future<void> getLocation() async {
    try {
      setState(() {
        locationText = "Getting location...";
        status = "";
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => locationText = "Location services disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => locationText = "Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => locationText = "Location permission permanently denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      latitude = position.latitude.toStringAsFixed(6);
      longitude = position.longitude.toStringAsFixed(6);

      setState(() {
        locationText = "Lat: $latitude, Lon: $longitude";
      });

      await platform.invokeMethod("updateLocation", {
        "latitude": latitude,
        "longitude": longitude
      });

    } catch (e) {
      setState(() => locationText = "Error getting location: $e");
    }
  }

  Future<void> sendLocationSms() async {
    try {
      setState(() => status = "Checking permissions...");

      // Request SMS permissions multiple times if needed
      bool? hasPermissions = await _requestSmsPermissionWithRetry();

      if (hasPermissions != true) {
        setState(() => status = "❌ SMS permissions not granted");
        return;
      }

      // Check if device can send SMS
      final bool? canSendSms = await telephony.isSmsCapable;
      if (canSendSms != true) {
        setState(() => status = "❌ Device cannot send SMS");
        return;
      }

      setState(() => status = "Sending emergency SMS...");

      // Create message
      final String message = _createEmergencyMessage();

      // Try multiple SMS sending methods
      await _sendSmsWithMultipleMethods(message);

    } catch (e) {
      setState(() => status = "❌ Failed to send SMS: $e");
      print("SMS Error: $e");
    }
  }

  Future<bool?> _requestSmsPermissionWithRetry() async {
    for (int i = 0; i < 3; i++) {
      bool? hasPermissions = await telephony.requestSmsPermissions;
      if (hasPermissions == true) {
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return false;
  }

  String _createEmergencyMessage() {
    return """ Emergency Alert!
My current location: 
https://maps.google.com/?q=$latitude+$longitude""";
  }

  Future<void> _sendSmsWithMultipleMethods(String message) async {
    // Method 1: Direct telephony sendSms
    try {
      print("Trying Method 1: Direct telephony sendSms");
      await telephony.sendSms(
        to: "+916282959311",
        message: message,
      );
      setState(() => status = "✅ Emergency SMS sent successfully!");
      print("SMS sent successfully via Method 1");
      return;
    } catch (e) {
      print("Method 1 failed: $e");
    }

    // Method 2: Use platform channels to send SMS via Android native code
    try {
      print("Trying Method 2: Platform channel to native Android");
      final bool result = await platform.invokeMethod('sendSms', {
        'phoneNumber': "6282959311",
        'message': message,
      });

      if (result) {
        setState(() => status = "✅ Emergency SMS sent successfully!");
        print("SMS sent successfully via Method 2");
        return;
      }
    } catch (e) {
      print("Method 2 failed: $e");
    }

    // Method 3: Try with different telephony approach
    try {
      print("Trying Method 3: Alternative approach");
      await _sendSmsAlternative(message);
      return;
    } catch (e) {
      print("Method 3 failed: $e");
    }

    throw Exception("All SMS sending methods failed");
  }

  Future<void> _sendSmsAlternative(String message) async {
    // Simple approach without status listener to avoid conflicts
    try {
      await telephony.sendSms(
        to: "+916282959311",
        message: message,
      );
      setState(() => status = "✅ Emergency SMS sent successfully!");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Emergency Alert"),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.location_on, size: 40, color: Colors.blue),
                      const SizedBox(height: 10),
                      const Text(
                        "Current Location",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        locationText,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: status.contains("✅") ? Colors.green.shade50 :
                  status.contains("❌") ? Colors.red.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    color: status.contains("✅") ? Colors.green :
                    status.contains("❌") ? Colors.red : Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),

              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: getLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh Location"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton.icon(
                    onPressed: sendLocationSms,
                    icon: const Icon(Icons.emergency),
                    label: const Text("Send Emergency SMS"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Press Volume Up/Down button to send emergency SMS automatically",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "No app will open - SMS sends in background",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}