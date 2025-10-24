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
import 'package:url_launcher/url_launcher.dart';

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

  // 🆕 VOLUME BUTTON VARIABLES
  int _volumeButtonPressCount = 0;
  Timer? _volumeButtonTimer;
  final int _requiredVolumePresses = 3;
  final Duration _volumePressTimeout = Duration(seconds: 2);

  // 🆕 SENSOR DATA BUFFER
  List<Map<String, double>> _sensorBuffer = [];
  final int _bufferSize = 10;

  //todo => Checking if the user accepts all the permissions
  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.storage,
      Permission.sensors,
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

    // 🆕 Add to buffer
    _addToSensorBuffer(sample);

    // 🆕 Calculate motion intensity for debugging
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

    // 🆕 Print strong motion for debugging
    if (accMagnitude > 18.0 || gyroMagnitude > 4.0) {
      print("💪 STRONG MOTION - "
          "Acc: ${accMagnitude.toStringAsFixed(2)} "
          "Gyro: ${gyroMagnitude.toStringAsFixed(2)} "
          "Buffer: ${_sensorBuffer.length}/$_bufferSize");
    }

    // Check if this is significant motion worth analyzing
    if (_isSignificantMotion(sample)) {
      _analyzeMotionPattern(_getSensorBuffer());
    }
  }

  // 🆕 BUFFER MANAGEMENT METHODS
  void _addToSensorBuffer(Map<String, double> sample) {
    _sensorBuffer.add(sample);
    if (_sensorBuffer.length > _bufferSize) {
      _sensorBuffer.removeAt(0);
    }
  }

  List<Map<String, double>> _getSensorBuffer() {
    return List.from(_sensorBuffer);
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

    // 🆕 Higher thresholds to ensure only violent motions are analyzed
    return accMagnitude > 20.0 || gyroMagnitude > 5.0;
  }

  // 🆕 VERIFY PHYSICAL MOTION INTENSITY
  bool _isViolentPhysicalMotion(List<Map<String, double>> samples) {
    if (samples.isEmpty) return false;

    double maxAccMagnitude = 0;
    double maxGyroMagnitude = 0;

    for (var sample in samples) {
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

      if (accMagnitude > maxAccMagnitude) maxAccMagnitude = accMagnitude;
      if (gyroMagnitude > maxGyroMagnitude) maxGyroMagnitude = gyroMagnitude;
    }

    print("💥 Max motion detected - Acc: ${maxAccMagnitude.toStringAsFixed(2)}, Gyro: ${maxGyroMagnitude.toStringAsFixed(2)}");

    // Require very strong physical motion
    return maxAccMagnitude > 25.0 || maxGyroMagnitude > 8.0;
  }

  // 🆕 ANALYZE MOTION PATTERN AND SEND TO BACKEND
  void _analyzeMotionPattern(List<Map<String, double>> samples) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? "";

      if (urls.isEmpty) {
        print("❌ URL not found for motion analysis");
        return;
      }

      var url = Uri.parse('$urls/myapp/predict-motion/');

      // 🆕 Print what we're sending
      print("📤 Sending ${samples.length} samples to API");
      if (samples.isNotEmpty) {
        var strongestSample = samples.reduce((a, b) {
          double aMag = sqrt(a['ax']! * a['ax']! + a['ay']! * a['ay']! + a['az']! * a['az']!);
          double bMag = sqrt(b['ax']! * b['ax']! + b['ay']! * b['ay']! + b['az']! * b['az']!);
          return aMag > bMag ? a : b;
        });
        print("💪 Strongest sample - "
            "ax: ${strongestSample['ax']!.toStringAsFixed(2)}, "
            "ay: ${strongestSample['ay']!.toStringAsFixed(2)}, "
            "az: ${strongestSample['az']!.toStringAsFixed(2)}");
      }

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"data": samples}),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("📥 API Response: $result");

        if (!result.containsKey('error')) {
          String predictedAction = result['action'];
          double confidence = result['confidence'];

          setState(() {
            _lastPrediction = predictedAction;
            _lastConfidence = confidence;
          });

          print("🎯 Motion prediction: $predictedAction (${(confidence * 100).toStringAsFixed(2)}%)");

          // 🚨 TRIGGER SOS ONLY FOR RAPID_SHAKE AND THROW WITH HIGH CONFIDENCE
          if ((predictedAction == "rapid_shake" || predictedAction == "throw") &&
              confidence > 0.9950 &&
              _isViolentPhysicalMotion(samples) &&
              !_sosTriggered) {
            print("🚨🚨🚨 DANGEROUS MOTION DETECTED: $predictedAction - Triggering SOS! 🚨🚨🚨");
            _triggerSOSFromMotion(predictedAction);
          } else if (confidence > 0.9950) {
            print("⚠️ High confidence but not violent enough or wrong action: $predictedAction");
          }
        }
      } else {
        print("❌ API Error: ${response.statusCode} - ${response.body}");
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

    // Clear buffer after detection
    _sensorBuffer.clear();

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

  // 🆕 HANDLE VOLUME BUTTON PRESSES
  void _handleVolumeButtonPress() {
    print("🔊 Volume button pressed - Count: ${_volumeButtonPressCount + 1}");

    // Reset timer if it's running
    _volumeButtonTimer?.cancel();

    // Increment press count
    setState(() {
      _volumeButtonPressCount++;
    });

    // Start/reset timer
    _volumeButtonTimer = Timer(_volumePressTimeout, () {
      print("⏰ Volume button timeout - Resetting count");
      setState(() {
        _volumeButtonPressCount = 0;
      });
    });

    // Check if we reached the required number of presses
    if (_volumeButtonPressCount >= _requiredVolumePresses) {
      print("🚨 3 volume presses detected - Triggering SOS!");
      _volumeButtonTimer?.cancel();
      setState(() {
        _volumeButtonPressCount = 0;
      });
      _triggerSOS();
    }
  }

  // 🆕 TEST METHOD FOR MOTION DETECTION
  void _testMotionDetection() {
    print("🧪 Testing motion detection with violent shake data...");

    // Create synthetic violent shake data
    List<Map<String, double>> testSamples = [];
    for (int i = 0; i < 10; i++) {
      testSamples.add({
        "ax": 8.0 + Random().nextDouble() * 5.0, // Very strong acceleration
        "ay": -7.0 + Random().nextDouble() * 4.0,
        "az": 12.0 + Random().nextDouble() * 3.0, // Well above gravity
        "gx": 10.0 + Random().nextDouble() * 6.0, // Very strong rotation
        "gy": -9.0 + Random().nextDouble() * 5.0,
        "gz": 4.0 + Random().nextDouble() * 3.0,
      });
    }

    print("💥 Test data created - very violent motion simulation");
    _analyzeMotionPattern(testSamples);
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
      print(response.body);
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

    // 🔊 Volume button listener with 3-press requirement
    const platform = MethodChannel('volume.channel');
    platform.setMethodCallHandler((call) async {
      if (call.method == "volumeButtonPressed" && !_sosTriggered) {
        _handleVolumeButtonPress();
      }
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _motionSamplingTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _volumeButtonTimer?.cancel();
    _speech.stop();
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
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
              const SizedBox(width: 40),
              _buildNavItem(Icons.contact_phone_rounded, 'Contact', 1),
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
          // 🆕 Volume press counter
          if (_volumeButtonPressCount > 0)
            Positioned(
              top: 50, left: 20,
              child: _VolumePressCounter(count: _volumeButtonPressCount),
            ),
          // 🆕 Motion detection test button (remove in production)
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: _testMotionDetection,
              child: Icon(Icons.bug_report),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
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

  void _onItemTapped(int index) {
    setState(() => selectedIndex = index);
  }

  final List<Widget> screens = [
    MainHome(),
    Set_emergency_number(title: "Emergency Number"),
  ];

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

  Widget _buildDrawer(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    Map<String, String> userProfile = {
      'Gender': 'Female',
      'D.O.B': '1995-05-15',
      'Phone': '+91 9876543210',
      'Email': 'user@example.com',
      'Place': 'Kochi',
      'Post': 'Ernakulam',
      'District': 'Ernakulam',
      'State': 'Kerala',
    };

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: width * 0.75,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8FB1), Color(0xFFFFC2D6)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 35,
                    color: Color(0xFFFF8FB1),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'SheCare User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Stay Safe, Stay Connected',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          textArea('Gender', userProfile['Gender'] ?? ''),
                          textArea('D.O.B', userProfile['D.O.B'] ?? ''),
                          textArea('Phone', userProfile['Phone'] ?? ''),
                          textArea('Email', userProfile['Email'] ?? ''),
                          textArea('Place', userProfile['Place'] ?? ''),
                          textArea('Post', userProfile['Post'] ?? ''),
                          textArea('District', userProfile['District'] ?? ''),
                          textArea('State', userProfile['State'] ?? ''),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.contact_phone_rounded,
                  title: 'Emergency Contacts',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Set_emergency_number(title: "Emergency Number"),
                    ),
                  ),
                ),
                const Divider(height: 20, indent: 16, endIndent: 16),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  color: Colors.red,
                  onTap: () => _showLogoutDialog(context),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget textArea(String label, String data, {bool isImportant = false, bool isHeader = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isImportant ? const Color(0xFFFFE3EC) : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isImportant ? const Color(0xFFFF8FB1) : const Color(0xFFFFC2D6),
          width: isImportant ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF8FB1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.isNotEmpty ? data : 'Not provided',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: data.isNotEmpty ? Colors.black87 : Colors.grey,
                fontStyle: data.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFE3EC) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? (isSelected ? const Color(0xFFFF8FB1) : Colors.grey[700]),
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: color ?? (isSelected ? const Color(0xFFFF8FB1) : Colors.grey[700]),
            fontSize: 16,
          ),
        ),
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

// Volume Press Counter Widget
class _VolumePressCounter extends StatelessWidget {
  final int count;

  const _VolumePressCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.volume_up, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            'SOS: $count/3',
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold
            ),
          ),
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
                      IconButton(onPressed: (){
                        _showLogoutDialog(context);
                      }, icon: Icon(Icons.logout_outlined))
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
                  _buildSectionCard(
                    title: '🚨 Emergency Helpline Numbers',
                    color: Colors.red,
                    children: [
                      _buildHelplineItem('Women Helpline', '1091', Icons.phone),
                      _buildHelplineItem('National Emergency', '112', Icons.emergency),
                      _buildHelplineItem('Police', '100', Icons.local_police),
                      _buildHelplineItem('Cyber Crime', '1930', Icons.computer),
                      _buildHelplineItem('Child Helpline', '1098', Icons.child_care),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: '💡 Safety Tips',
                    color: Colors.orange,
                    children: [
                      _buildTipItem('Share your live location with trusted contacts when traveling'),
                      _buildTipItem('Trust your instincts - if something feels wrong, it probably is'),
                      _buildTipItem('Keep your phone charged and emergency numbers saved'),
                      _buildTipItem('Avoid isolated areas, especially during late hours'),
                      _buildTipItem('Be aware of your surroundings at all times'),
                      _buildTipItem('Learn basic self-defense techniques'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: '🥊 Quick Self-Defense Tips',
                    color: Colors.purple,
                    children: [
                      _buildTipItem('Target vulnerable areas: eyes, nose, throat, groin'),
                      _buildTipItem('Make noise - scream and attract attention'),
                      _buildTipItem('Use everyday items as weapons (keys, umbrella, bag)'),
                      _buildTipItem('Create distance and escape immediately'),
                      _buildTipItem('Never hesitate to fight back if in danger'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: '📱 Digital Safety',
                    color: Colors.blue,
                    children: [
                      _buildTipItem('Don\'t share personal information with strangers online'),
                      _buildTipItem('Use strong passwords and enable two-factor authentication'),
                      _buildTipItem('Be cautious of suspicious links and messages'),
                      _buildTipItem('Review privacy settings on social media regularly'),
                      _buildTipItem('Report cyberbullying and harassment immediately'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: '🚗 Travel Safety',
                    color: Colors.green,
                    children: [
                      _buildTipItem('Verify cab details before getting in (number plate, driver photo)'),
                      _buildTipItem('Sit in the back seat and keep doors locked'),
                      _buildTipItem('Share trip details with family or friends'),
                      _buildTipItem('Avoid traveling alone late at night when possible'),
                      _buildTipItem('Keep emergency contacts on speed dial'),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelplineItem(String name, String number, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: () {
              openDialer(number);
            },
          ),
        ],
      ),
    );
  }

  void openDialer(String phoneNumber) async {
    final Uri dialUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(dialUri)) {
      await launchUrl(dialUri);
    } else {
      throw 'Could not open dialer';
    }
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetySection extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  const _SafetySection({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: items.map((item) => _SafetyTipItem(tip: item)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyTipItem extends StatelessWidget {
  final String tip;

  const _SafetyTipItem({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.pink,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}