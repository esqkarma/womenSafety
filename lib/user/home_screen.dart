import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shecare/login.dart';
import 'package:shecare/hm/data.dart';
import 'package:shecare/sos_service.dart';
import 'package:shecare/user/add_dangerous_spot.dart';
import 'package:shecare/user/audio_em.dart';
import 'package:shecare/user/chat_bot.dart';
import 'package:shecare/user/emergency_number.dart';
import 'package:shecare/user/search_nearby_users.dart';
import 'package:shecare/user/send_visuals.dart';
import 'package:shecare/user/view_dangerous_spot.dart';
import 'package:shecare/user/view_ideas_and_image.dart';
import 'package:shecare/user/view_my_dangerous_spot.dart';
import 'package:shecare/user/viewnearestpinkpolice.dart';
import 'package:shecare/user/viewreplies.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

class UserHome extends StatefulWidget {
  const UserHome({Key? key}) : super(key: key);

  static const String id = 'HomeScreen';

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int selectedIndex = 0;
  List<dynamic> phn = [];
  List userData = [];

  // Voice detection
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = "Initializing speech...";
  double _confidence = 1.0;
  final List<String> targetWords = ["help", "emergency", "sos", "save me", "danger", "help me"];

  // Audio recording and sending
  bool _isRecording = false;
  String? _currentAudioPath;
  Timer? _recordingTimer;
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final int _recordingInterval = 30;

  // SOS trigger flag
  bool _sosTriggered = false;
  bool isMicButtonPressed = false;

  // 🆕 MOTION DETECTION VARIABLES
  AccelerometerEvent? _lastAccelerometer;
  GyroscopeEvent? _lastGyroscope;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  Timer? _motionSamplingTimer;
  final int _samplingRate = 33; // ~30Hz in milliseconds

  // Motion detection state
  String _currentMotion = "monitoring";
  String _lastPrediction = "none";
  double _lastConfidence = 0.0;
  bool _motionDetectionActive = true;

  //todo => Checking if the user accepts all the permissions
  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.storage,
      Permission.sensors, // 🆕 Add sensor permission
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) {
      Fluttertoast.showToast(msg: 'Microphone, storage and sensor permissions required');
    }
    return allGranted;
  }

  //todo => initialize Audio recorder
  Future<void> _initAudioRecorder() async {
    try {
      await _audioRecorder.openRecorder();
      await _audioRecorder.setSubscriptionDuration(const Duration(milliseconds: 10));
      print("✅ Audio recorder initialized successfully");
    } catch (e) {
      print("❌ Error initializing audio recorder: $e");
    }
  }

  // 🆕 INITIALIZE MOTION DETECTION
  void _startMotionDetection() async {
    if (!_motionDetectionActive) return;

    // Listen to accelerometer
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          _lastAccelerometer = event;
        });
      }
    });

    // Listen to gyroscope
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      if (mounted) {
        setState(() {
          _lastGyroscope = event;
        });
      }
    });

    // Start synchronized sampling timer
    _motionSamplingTimer = Timer.periodic(Duration(milliseconds: _samplingRate), (timer) {
      _checkMotionForSOS();
    });

    print("✅ Motion detection started");
  }

  // 🆕 CHECK MOTION AND TRIGGER SOS FOR SPECIFIC MOTIONS
  void _checkMotionForSOS() {
    if (_lastAccelerometer == null || _lastGyroscope == null || _sosTriggered) return;

    Map<String, double> sample = {
      "ax": _lastAccelerometer!.x,
      "ay": _lastAccelerometer!.y,
      "az": _lastAccelerometer!.z,
      "gx": _lastGyroscope!.x,
      "gy": _lastGyroscope!.y,
      "gz": _lastGyroscope!.z,
    };

    // Check if this is significant motion worth analyzing
    if (_isSignificantMotion(sample)) {
      _analyzeMotionPattern(sample);
    }
  }

  // 🆕 CHECK IF MOTION IS SIGNIFICANT ENOUGH TO ANALYZE
  bool _isSignificantMotion(Map<String, double> sample) {
    double accMagnitude = sqrt(
        sample['ax']! * sample['ax']! +
            sample['ay']! * sample['ay']! +
            sample['az']! * sample['az']!
    );

    double gyroMagnitude = sqrt(
        sample['gx']! * sample['gx']! +
            sample['gy']! * sample['gy']! +
            sample['gz']! * sample['gz']!
    );

    return accMagnitude > 15.0 || gyroMagnitude > 3.0;
  }

  // 🆕 ANALYZE MOTION PATTERN AND SEND TO BACKEND
  void _analyzeMotionPattern(Map<String, double> sample) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? "";

      if (urls.isEmpty) {
        print("❌ URL not found for motion analysis");
        return;
      }

      var url = Uri.parse('$urls/myapp/predict-motion/');

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"data": [sample]}),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        if (!result.containsKey('error')) {
          String predictedAction = result['action'];
          double confidence = result['confidence'];

          setState(() {
            _lastPrediction = predictedAction;
            _lastConfidence = confidence;
          });

          print("🎯 Motion detected: $predictedAction (${(confidence * 100).toStringAsFixed(1)}%)");

          // 🚨 TRIGGER SOS ONLY FOR RAPID_SHAKE AND THROW
          if ((predictedAction == "rapid_shake" || predictedAction == "throw") &&
              confidence > 0.9950 && !_sosTriggered) {
            print("🚨 DANGEROUS MOTION DETECTED: $predictedAction - Triggering SOS!");
            _triggerSOSFromMotion(predictedAction);
          }
        }
      }
    } catch (e) {
      print("❌ Motion analysis error: $e");
    }
  }

  // 🆕 TRIGGER SOS FROM MOTION DETECTION
  Future<void> _triggerSOSFromMotion(String motionType) async {
    if (_sosTriggered) return;

    print("🚨🚨🚨 SOS ACTIVATED by $motionType! 🚨🚨🚨");

    setState(() {
      _sosTriggered = true;
      _currentMotion = "sos_activated";
    });

    // Stop all activities
    if (_speech.isListening) _speech.stop();
    if (_isRecording) await _stopRecording();

    // Show immediate feedback
    Fluttertoast.showToast(
      msg: '🚨 SOS ACTIVATED! $motionType detected - Sending alerts...',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );

    // Send SOS alerts
    await SOSService.triggerSOS(phone: phn);

    // Reset after 15 seconds
    Timer(const Duration(seconds: 15), () {
      print("🔄 Resetting SOS state after motion detection");
      setState(() {
        _sosTriggered = false;
        _currentMotion = "monitoring";
      });
      _restartListening();
    });
  }

  Future<void> initSpeechToText() async {
    bool permissionGranted = await _requestPermissions();
    if (!permissionGranted) return;

    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          final text = result.recognizedWords.toLowerCase();
          print('Heard: $text');
          if (text.contains('help')) {
            _triggerSOS();
          }
        },
        listenMode: ListenMode.confirmation,
      );
    } else {
      Fluttertoast.showToast(msg: 'Speech recognition not available');
    }
  }

  Future<void> _initSpeech() async {
    bool speechAvailable = await _speech.initialize(
      onStatus: (status) {
        print('🎤 Speech Status: $status');
        if (status == 'done' && _isListening && !_sosTriggered) {
          _restartListening();
        } else if (status == 'listening') {
          setState(() => _text = "Listening... Say 'help' for SOS");
        }
      },
      onError: (error) {
        print('❌ Speech Error: ${error.errorMsg}, permanent: ${error.permanent}');
        if (error.errorMsg == 'error_permission') {
          setState(() => _text = "Speech permission issue - using fallback");
        } else if (!_sosTriggered) {
          Timer(const Duration(seconds: 2), _restartListening);
        }
      },
    );

    if (speechAvailable) {
      setState(() {
        _isListening = true;
        _text = "Ready - Say 'help' for SOS";
      });
      _startListening();
      print("✅ Speech recognition initialized successfully");
    } else {
      setState(() => _text = "Speech recognition unavailable - using other SOS methods");
    }
  }

  void _restartListening() {
    if (!_sosTriggered && !_speech.isListening) {
      Timer(const Duration(seconds: 1), _startListening);
    }
  }

  void _startListening() {
    if (_speech.isListening || _sosTriggered) return;

    try {
      _speech.listen(
        onResult: (result) {
          String recognizedText = result.recognizedWords.toLowerCase();
          setState(() {
            _text = "Heard: $recognizedText";
          });

          print("🎯 Speech detected: $recognizedText");

          for (String target in targetWords) {
            if (recognizedText.contains(target) && !_sosTriggered) {
              print("🚨 TARGET WORD DETECTED: '$target' in '$recognizedText'");
              _triggerSOS();
              break;
            }
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        localeId: "en_US",
        listenMode: stt.ListenMode.confirmation,
      );
    } catch (e) {
      print("❌ Error starting speech: $e");
    }
  }

  // 🚨 SOS Trigger Function
  Future<void> _triggerSOS() async {
    if (_sosTriggered) return;

    print("🚨🚨🚨 SOS ACTIVATED! 🚨🚨🚨");

    setState(() {
      _sosTriggered = true;
      _text = "🚨 SOS ACTIVATED - Sending alerts...";
    });

    if (_speech.isListening) _speech.stop();
    if (_isRecording) await _stopRecording();

    Fluttertoast.showToast(
      msg: '🚨 SOS ACTIVATED! Sending alerts...',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );

    await SOSService.triggerSOS(phone: phn);

    Timer(const Duration(seconds: 3), () {
      print("🔄 Resetting SOS state");
      setState(() {
        _sosTriggered = false;
        _text = "Ready - Say 'help' for SOS";
      });
      _restartListening();
    });
  }

  Future<void> _startRecording() async {
    if (_isRecording || _sosTriggered) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentAudioPath = '${tempDir.path}/audio$timestamp.m4a';

      await _audioRecorder.startRecorder(
        toFile: _currentAudioPath,
        codec: Codec.aacMP4,
        audioSource: AudioSource.microphone,
      );

      setState(() => _isRecording = true);
      print("🎤 Recording started: $_currentAudioPath");
    } catch (e) {
      print("❌ Recording error: $e");
      setState(() => _isRecording = false);
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (!_isRecording) return;
      await _audioRecorder.stopRecorder();
      setState(() => _isRecording = false);
      print("⏹️ Recording stopped");
    } catch (e) {
      print("❌ Stop recording error: $e");
      setState(() => _isRecording = false);
    }
  }

  Future<void> _stopRecordingAndSend() async {
    try {
      if (!_isRecording || _sosTriggered) return;

      await _audioRecorder.stopRecorder();
      setState(() => _isRecording = false);

      final audioFile = File(_currentAudioPath!);
      if (await audioFile.exists() && await audioFile.length() > 0) {
        await _sendAudioToBackend(_currentAudioPath!);
      } else {
        print("⚠️ No audio to send");
      }
    } catch (e) {
      print("❌ Stop/send error: $e");
      setState(() => _isRecording = false);
    }
  }

  Future<void> _sendAudioToBackend(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('❌ File does not exist: $filePath');
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url = prefs.getString('url') ?? '';
      if (url.isEmpty) {
        print('❌ No backend URL found');
        return;
      }

      final request = http.MultipartRequest('POST', Uri.parse('$url/myapp/recordings/'))
        ..files.add(await http.MultipartFile.fromPath(
          'audio',
          file.path,
          filename: 'child_audio.wav',
        ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('✅ Audio sent successfully: ${response.body}');
        await file.delete();
        print('🗑 Local audio file deleted');
      } else {
        print('❌ Audio upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Send audio error: $e');
    }
  }

  // Fetch emergency contacts
  Future<void> fetchContacts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String urls = prefs.getString('url') ?? '';
      String lid = prefs.getString('lid') ?? '';

      if (urls.isEmpty) {
        print("❌ No backend URL configured");
        return;
      }

      String url = '$urls/myapp/user_view_emergency_number/';
      print("🔗 Fetching contacts from: $url");

      var response = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsonData = json.decode(response.body);
      var data = jsonData['data'];

      List<dynamic> numbers = [];
      for (var contact in data) {
        String number = contact['number'].toString();
        numbers.add(number);
        print("📞 Found emergency number: $number");
      }

      setState(() => phn = numbers);

      if (phn.isEmpty) {
        print("⚠️ No emergency numbers found");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please add emergency numbers")));
      } else {
        print("✅ Loaded ${phn.length} emergency numbers");
      }
    } catch (e) {
      print("❌ Error fetching contacts: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _startListening();
    fetchContacts();
    _initSpeech();
    _initAudioRecorder();

    // 🆕 START MOTION DETECTION
    _startMotionDetection();

    // 🔊 Volume button listener
    const platform = MethodChannel('volume.channel');
    platform.setMethodCallHandler((call) async {
      if (call.method == "volumeButtonPressed" && !_sosTriggered) {
        print("🔊 Volume button - triggering SOS");
        _triggerSOS();
      }
    });

  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _motionSamplingTimer?.cancel(); // 🆕 Stop motion timer
    _accelerometerSubscription?.cancel(); // 🆕 Stop accelerometer
    _gyroscopeSubscription?.cancel(); // 🆕 Stop gyroscope
    _speech.stop();
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.contact_phone_rounded, 'Contact', 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.people_rounded, 'Users', 2),
              _buildNavItem(Icons.lightbulb_rounded, 'Ideas', 3),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          screens[selectedIndex],
          // Status indicators
          if (_isRecording)
            Positioned(
              top: 50, right: 20,
              child: _StatusIndicator(icon: Icons.mic, text: 'Recording', color: Colors.red),
            ),
          // 🆕 Motion detection status

          // 🆕 SOS Alert from motion

        ],
      ),
      drawer: _buildDrawer(context),
      floatingActionButton: isMicButtonPressed ? FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          _stopRecording();
          _stopRecordingAndSend();
          setState(() {
            isMicButtonPressed = false;
          });
        }, child: Icon(Icons.stop),) : FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          _initAudioRecorder();
          _startRecording();
          setState(() {
            isMicButtonPressed = true;
          });
        }, child: Icon(Icons.mic),),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // 🆕 HELPER FUNCTIONS FOR MOTION DETECTION UI
  IconData _getMotionIcon(String motion) {
    switch (motion) {
      case "rapid_shake":
        return Icons.vibration;
      case "throw":
        return Icons.flight_takeoff;
      case "shake":
        return Icons.waves;
      case "fall":
        return Icons.arrow_downward;
      default:
        return Icons.directions_walk;
    }
  }

  Color _getMotionColor(String motion) {
    switch (motion) {
      case "rapid_shake":
      case "throw":
        return Colors.red;
      case "shake":
        return Colors.orange;
      case "fall":
        return Colors.yellow[700]!;
      default:
        return Colors.green;
    }
  }

  // ... rest of your existing methods (buildNavItem, buildDrawer, etc.) remain the same
  void _onItemTapped(int index) {
    setState(() => selectedIndex = index);
  }

  final List<Widget> screens = [
    MainHome(),
    Set_emergency_number(title: "Emergency Number"),
    Search_nearby_users(title: "Search Nearby Users"),
    View_ideas_and_image(title: "View Ideas"),
    view_replies(title: "View Complaint"),
  ];

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8FB1), Color(0xFFFFC2D6)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.3), blurRadius: 10)],
                  ),
                  child: const Icon(Icons.person_rounded, size: 40, color: Color(0xFFFF8FB1)),
                ),
                const SizedBox(height: 16),
                const Text('SheCare User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                const Text('Stay Safe, Stay Connected', style: TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          _buildDrawerItem(icon: Icons.dashboard_rounded, title: 'Dashboard', isSelected: true, onTap: () => Navigator.pop(context)),
          _buildDrawerItem(icon: Icons.emergency_rounded, title: 'Emergency Call', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => View_near_pink_police()))),
          _buildDrawerItem(icon: Icons.warning_amber_rounded, title: 'Dangerous Spots', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => View_dangerous_spot(title: "View Dangerous Spot")))),
          _buildDrawerItem(icon: Icons.camera_alt_rounded, title: 'Send Visuals', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CameraPage()))),
          const Divider(height: 20, indent: 16, endIndent: 16),
          _buildDrawerItem(icon: Icons.contact_phone_rounded, title: 'Emergency Contacts', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Set_emergency_number(title: "Emergency Number")))),
          _buildDrawerItem(icon: Icons.people_rounded, title: 'Nearby Users', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Search_nearby_users(title: "Search Nearby Users")))),
          _buildDrawerItem(icon: Icons.lightbulb_rounded, title: 'Ideas & Tips', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => View_ideas_and_image(title: "View ideas")))),
          const Divider(height: 20, indent: 16, endIndent: 16),
          _buildDrawerItem(icon: Icons.logout_rounded, title: 'Logout', color: Colors.red, onTap: () => _showLogoutDialog(context)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap, bool isSelected = false, Color? color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFE3EC) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? (isSelected ? const Color(0xFFFF8FB1) : Colors.grey[700]), size: 24),
        title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: color ?? (isSelected ? const Color(0xFFFF8FB1) : Colors.grey[700]), fontSize: 16)),
        trailing: isSelected ? const Icon(Icons.circle, size: 8, color: Color(0xFFFF8FB1)) : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.pink : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.pink : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.1)),
                  child: const Icon(Icons.logout_rounded, size: 30, color: Colors.red),
                ),
                const SizedBox(height: 16),
                const Text('Logout', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Are you sure you want to logout?', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(foregroundColor: Colors.grey, side: const BorderSide(color: Colors.grey), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Cancel'))),
                    const SizedBox(width: 16),
                    Expanded(child: ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Logout'))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Status Indicator Widget
class _StatusIndicator extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _StatusIndicator({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}


class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFE3EC),
                  Color(0xFFFFC2D6),
                  Color(0xFFFF8FB1),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu_rounded, color: Colors.black),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        const Text(
                          "SheCare",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                      const SizedBox(width: 48),
                      IconButton(
                        onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>ChatScreen()));
                        },
                        icon: Icon(Icons.chat),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back,',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'User!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your safety is our priority',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 500,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: recommended.length,
                      itemBuilder: (context, index) {
                        return _FeatureCard(
                          icon: _getIconForFeature(recommended[index].plantType),
                          title: recommended[index].plantType,
                          subtitle: recommended[index].plantName,
                          color: _getColorForFeature(recommended[index].plantType),
                          onTap: () {
                            _handleFeatureTap(recommended[index].plantType, context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForFeature(String plantType) {
    switch (plantType) {
      case 'Emergency Call':
        return Icons.emergency_rounded;
      case 'Dangerous Spot':
        return Icons.warning_amber_rounded;
      case 'View All Dangerous Spot':
        return Icons.location_pin;
      case 'View My Dangerous Spot':
        return Icons.my_location_rounded;
      case 'Send Visuals':
        return Icons.camera_alt_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  Color _getColorForFeature(String plantType) {
    switch (plantType) {
      case 'Emergency Call':
        return Colors.red;
      case 'Dangerous Spot':
        return Colors.orange;
      case 'View All Dangerous Spot':
        return Colors.purple;
      case 'View My Dangerous Spot':
        return Colors.blue;
      case 'Send Visuals':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _handleFeatureTap(String plantType, BuildContext context) {
    Fluttertoast.showToast(msg: plantType);
    switch (plantType) {
      case 'Emergency Call':
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => View_near_pink_police()));
        break;
      case 'Dangerous Spot':
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => User_Add_dangerous_spot(title: "Dangerous Spot")));
        break;
      case 'View All Dangerous Spot':
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => View_dangerous_spot(title: "View Dangerous Spot")));
        break;
      case 'View My Dangerous Spot':
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => view_my_dangerous_spot(title: "View My Dangerous Spot")));
        break;
      case 'Send Visuals':
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => RecordAndSendAudio()));
        break;
    }
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}