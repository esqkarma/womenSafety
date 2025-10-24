import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EmotionCameraPage(cameras: cameras),
    );
  }
}

class EmotionCameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const EmotionCameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<EmotionCameraPage> createState() => _EmotionCameraPageState();
}

class _EmotionCameraPageState extends State<EmotionCameraPage> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  String _emotion = "Waiting...";
  late Interpreter _interpreter;
  Timer? _timer;
  int _secondsPassed = 0;

  @override
  void initState() {
    super.initState();
    _initModelAndCamera();
  }

  Future<void> _initModelAndCamera() async {
    // Load TFLite model
    try {
      _interpreter = await Interpreter.fromAsset('assets/emotion_model.tflite');
      print("✅ Model loaded successfully");
    } catch (e) {
      print("❌ Error loading model: $e");
      return;
    }

    // Initialize front camera
    final frontCamera = widget.cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController =
        CameraController(frontCamera, ResolutionPreset.low, enableAudio: false);

    try {
      await _cameraController.initialize();
      setState(() => _isCameraInitialized = true);

      // Timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsPassed++;
        });
      });

      // Start image stream
      _cameraController.startImageStream(_processImage);
    } catch (e) {
      print("❌ Camera init error: $e");
    }
  }

  void _processImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final rgbImage = _convertYUV420ToRGB(image);
      final emotion = await _predictEmotion(rgbImage);

      setState(() {
        _emotion = emotion;
      });
    } catch (e) {
      print("❌ Error detecting emotion: $e");
    } finally {
      _isDetecting = false;
    }
  }

  // Convert YUV420 image to RGB Image
  img.Image _convertYUV420ToRGB(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final img.Image rgbImage = img.Image(width, height);

    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yp = yPlane[y * width + x].toInt();
        final uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);
        final u = uPlane[uvIndex].toInt();
        final v = vPlane[uvIndex].toInt();

        int r = (yp + 1.402 * (v - 128)).toInt().clamp(0, 255);
        int g = (yp - 0.344 * (u - 128) - 0.714 * (v - 128)).toInt().clamp(0, 255);
        int b = (yp + 1.772 * (u - 128)).toInt().clamp(0, 255);

        rgbImage.setPixelRgba(x, y, r, g, b);
      }
    }

    return rgbImage;
  }

  Future<String> _predictEmotion(img.Image image) async {
    final resized = img.copyResize(image, width: 48, height: 48);

    // Flattened RGB input
    final input = Float32List(1 * 48 * 48 * 3);
    for (int y = 0; y < 48; y++) {
      for (int x = 0; x < 48; x++) {
        final pixel = resized.getPixel(x, y);
        final r = ((pixel >> 16) & 0xFF) / 255.0;
        final g = ((pixel >> 8) & 0xFF) / 255.0;
        final b = (pixel & 0xFF) / 255.0;
        final index = (y * 48 + x) * 3;
        input[index] = r;
        input[index + 1] = g;
        input[index + 2] = b;
      }
    }

    var input4D = input.reshape([1, 48, 48, 3]);

    // Output buffer
    var output = Float32List(7).reshape([1, 7]);

    _interpreter.run(input4D, output);

    final emotions = ["Angry", "Disgust", "Fear", "Happy", "Sad", "Surprise", "Neutral"];

    int maxIndex = 0;
    double maxValue = output[0][0];
    for (int i = 1; i < 7; i++) {
      if (output[0][i] > maxValue) {
        maxValue = output[0][i];
        maxIndex = i;
      }
    }

    return emotions[maxIndex];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          CameraPreview(_cameraController),

          Positioned(
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Emotion: $_emotion",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
