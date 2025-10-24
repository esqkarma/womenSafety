import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpeechTrigger(),
    );
  }
}

class SpeechTrigger extends StatefulWidget {
  @override
  _SpeechTriggerState createState() => _SpeechTriggerState();
}

class _SpeechTriggerState extends State<SpeechTrigger> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = "Initializing...";
  double _confidence = 1.0;

  // 🎯 Target word
  String target = "hello";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      setState(() => _text = "Microphone permission denied");
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) async {
        print('Status: $status');
        if (status == 'done' && _isListening) {
          // Add a short delay before resuming
          await Future.delayed(const Duration(seconds: 1));
          if (!_speech.isListening) {
            _startListening();
          }
        }
      },
      onError: (error) async {
        print('Error: $error');
        // Wait before retrying to avoid busy loop
        await Future.delayed(const Duration(seconds: 2));
        if (!_speech.isListening) {
          _startListening();
        }
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _startListening();
    } else {
      setState(() => _text = "Speech recognition not available");
    }
  }

  void _startListening() {
    if (_speech.isListening) return; // Prevent overlapping sessions

    _speech.listen(
      onResult: (val) {
        setState(() {
          _text = val.recognizedWords;
          if (val.hasConfidenceRating && val.confidence > 0) {
            _confidence = val.confidence;
          }

          if (_text.toLowerCase().contains(target.toLowerCase())) {
            _speech.stop();
            _showTriggerDialog();
          }
        });
      },
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      cancelOnError: true,
      localeId: "en_US",
    );
  }

  void _showTriggerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade100,
        title: const Text("🎯 Trigger Detected"),
        content: Text("The word '$target' was spoken!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Future.delayed(const Duration(seconds: 1), _startListening);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Speech Command Detector',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _text,
            style: const TextStyle(color: Colors.white, fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}