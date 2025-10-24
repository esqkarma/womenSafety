import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RecordAndSendAudio extends StatefulWidget {
  const RecordAndSendAudio({super.key});

  @override
  State<RecordAndSendAudio> createState() => _RecordAndSendAudioState();
}

class _RecordAndSendAudioState extends State<RecordAndSendAudio> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    final dir = await getTemporaryDirectory();
    _filePath = '${dir.path}/recorded_audio.aac';

    await _recorder.startRecorder(toFile: _filePath, codec: Codec.aacADTS);
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);
  }

  Future<void> _sendAudioToPython() async {
    if (_filePath == null) {
      Fluttertoast.showToast(msg: 'No audio recorded yet');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = prefs.getString('url') ?? '';

    if (url.isEmpty) {
      Fluttertoast.showToast(msg: 'Backend URL not found in SharedPreferences');
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/myapp/recordings/'),
    );
    request.files.add(await http.MultipartFile.fromPath('audio', _filePath!));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Audio Sent Successfully ✅');
      debugPrint('Response: $responseBody');
    } else {
      Fluttertoast.showToast(msg: 'Failed to send audio ❌');
      debugPrint('Error: ${response.statusCode} - $responseBody');
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🎤 Record & Send Audio")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              color: _isRecording ? Colors.red : Colors.black,
              size: 100,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendAudioToPython,
              child: const Text('Send to Python Server'),
            ),
          ],
        ),
      ),
    );
  }
}
