import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as Math;

class MotionDetectionPage extends StatefulWidget {
  @override
  _MotionDetectionPageState createState() => _MotionDetectionPageState();
}

class _MotionDetectionPageState extends State<MotionDetectionPage> {
  List<Map<String, double>> sensorBuffer = [];
  final int bufferSize = 30; // ~1 second window at 30Hz

  AccelerometerEvent? _lastAccelerometer;
  GyroscopeEvent? _lastGyroscope;
  int _sampleCount = 0;
  bool _isListening = false;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  // Timer for synchronized sampling
  Timer? _samplingTimer;
  final int samplingRate = 33; // ~30Hz in milliseconds

  // Spike detection variables
  double _accThreshold = 2.0; // Acceleration threshold for spike (m/s²)
  double _gyroThreshold = 0.5; // Gyroscope threshold for spike (rad/s)
  List<double> _lastAccMagnitudes = [];
  List<double> _lastGyroMagnitudes = [];
  final int _smoothingWindow = 5; // Smoothing window for baseline calculation
  bool _isSpikeDetected = false;
  int _spikeCounter = 0;

  @override
  void initState() {
    super.initState();
    _startSensorListening();
  }

  void _startSensorListening() {
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
    _samplingTimer = Timer.periodic(Duration(milliseconds: samplingRate), (timer) {
      _addSynchronizedSample();
    });

    _isListening = true;
  }

  void _addSynchronizedSample() {
    // Only add sample if we have both sensor readings
    if (_lastAccelerometer != null && _lastGyroscope != null) {
      Map<String, double> sample = {
        "ax": _lastAccelerometer!.x,
        "ay": _lastAccelerometer!.y,
        "az": _lastAccelerometer!.z,
        "gx": _lastGyroscope!.x,
        "gy": _lastGyroscope!.y,
        "gz": _lastGyroscope!.z,
      };

      // Check for spike in sensor values
      bool hasSpike = _checkForSpike(sample);

      // Add to buffer for display
      sensorBuffer.add(sample);
      _sampleCount++;

      // Keep buffer at reasonable size for UI
      if (sensorBuffer.length > bufferSize) {
        sensorBuffer.removeAt(0);
      }

      // Only send data if spike is detected
      if (hasSpike) {
        _spikeCounter++;
        print('Spike detected! Count: $_spikeCounter');
        _sendSingleSensorData(sample);
      }

      print('Sample ${sensorBuffer.length}: ${_isSpikeDetected ? "SPIKE" : "normal"}');
    }
  }

  bool _checkForSpike(Map<String, double> sample) {
    // Calculate acceleration magnitude (excluding gravity)
    double accMagnitude = _calculateAccelerationMagnitude(sample);

    // Calculate gyroscope magnitude
    double gyroMagnitude = _calculateGyroscopeMagnitude(sample);

    // Update magnitude buffers
    _updateMagnitudeBuffers(accMagnitude, gyroMagnitude);

    // Check for spikes
    bool accSpike = _checkAccelerationSpike(accMagnitude);
    bool gyroSpike = _checkGyroscopeSpike(gyroMagnitude);

    _isSpikeDetected = accSpike || gyroSpike;

    return _isSpikeDetected;
  }

  double _calculateAccelerationMagnitude(Map<String, double> sample) {
    // Remove gravity component from z-axis (assuming device is mostly upright)
    double ax = sample['ax']!;
    double ay = sample['ay']!;
    double az = sample['az']! - 9.8; // Subtract gravity

    return Math.sqrt(ax * ax + ay * ay + az * az);
  }

  double _calculateGyroscopeMagnitude(Map<String, double> sample) {
    double gx = sample['gx']!;
    double gy = sample['gy']!;
    double gz = sample['gz']!;

    return Math.sqrt(gx * gx + gy * gy + gz * gz);
  }

  void _updateMagnitudeBuffers(double accMagnitude, double gyroMagnitude) {
    _lastAccMagnitudes.add(accMagnitude);
    _lastGyroMagnitudes.add(gyroMagnitude);

    // Keep only the last N magnitudes for smoothing
    if (_lastAccMagnitudes.length > _smoothingWindow) {
      _lastAccMagnitudes.removeAt(0);
    }
    if (_lastGyroMagnitudes.length > _smoothingWindow) {
      _lastGyroMagnitudes.removeAt(0);
    }
  }

  bool _checkAccelerationSpike(double currentAccMag) {
    if (_lastAccMagnitudes.length < _smoothingWindow) return false;

    // Calculate moving average for baseline
    double baseline = _lastAccMagnitudes.reduce((a, b) => a + b) / _lastAccMagnitudes.length;

    // Check if current magnitude exceeds threshold and is significantly above baseline
    bool isSpike = currentAccMag > _accThreshold && currentAccMag > baseline * 1.5;

    if (isSpike) {
      print('Acceleration spike: $currentAccMag (baseline: ${baseline.toStringAsFixed(3)})');
    }

    return isSpike;
  }

  bool _checkGyroscopeSpike(double currentGyroMag) {
    if (_lastGyroMagnitudes.length < _smoothingWindow) return false;

    // Calculate moving average for baseline
    double baseline = _lastGyroMagnitudes.reduce((a, b) => a + b) / _lastGyroMagnitudes.length;

    // Check if current magnitude exceeds threshold and is significantly above baseline
    bool isSpike = currentGyroMag > _gyroThreshold && currentGyroMag > baseline * 2.0;

    if (isSpike) {
      print('Gyroscope spike: $currentGyroMag (baseline: ${baseline.toStringAsFixed(3)})');
    }

    return isSpike;
  }

  Future<void> _sendSingleSensorData(Map<String, double> sample) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String urls = sh.getString('url') ?? "";

    if (urls.isEmpty) {
      print("URL not found in SharedPreferences");
      return;
    }

    var url = Uri.parse('$urls/myapp/predict-motion/');

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "data": [sample],
          "spike_detected": true,
          "spike_count": _spikeCounter,
          "timestamp": DateTime.now().millisecondsSinceEpoch
        }),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        if (result.containsKey('error')) {
          print('Server returned error: ${result['error']}');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("🚀 ${result['action']} (${(result['confidence'] * 100).toStringAsFixed(1)}%)"),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.orange,
              ),
            );
          }
          print('Prediction during spike: ${result['action']}');
        }
      }
    } catch (e) {
      print("Error sending sensor data: $e");
    }
  }

  void _stopSensorListening() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _samplingTimer?.cancel();
    _isListening = false;
  }

  void _clearBuffer() {
    setState(() {
      sensorBuffer.clear();
      _sampleCount = 0;
      _spikeCounter = 0;
      _lastAccMagnitudes.clear();
      _lastGyroMagnitudes.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Buffer cleared"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _toggleListening() {
    setState(() {
      if (_isListening) {
        _stopSensorListening();
      } else {
        _startSensorListening();
      }
    });
  }

  void _adjustThresholds(double accMultiplier, double gyroMultiplier) {
    setState(() {
      _accThreshold *= accMultiplier;
      _gyroThreshold *= gyroMultiplier;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Thresholds adjusted: Acc=${_accThreshold.toStringAsFixed(1)}, Gyro=${_gyroThreshold.toStringAsFixed(2)}"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _stopSensorListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Motion Detection"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.tune),
            onPressed: () => _showThresholdSettings(),
            tooltip: 'Adjust Sensitivity',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Status:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isSpikeDetected ? Colors.orange :
                            _isListening ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _isSpikeDetected ? "SPIKE DETECTED!" :
                            _isListening ? "LISTENING" : "PAUSED",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Buffer:"),
                        Text("${sensorBuffer.length} / $bufferSize"),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Samples:"),
                        Text("$_sampleCount"),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Spikes Detected:"),
                        Text("$_spikeCounter", style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Threshold info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Acc Threshold:"),
                        Text("${_accThreshold.toStringAsFixed(1)} m/s²"),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Gyro Threshold:"),
                        Text("${_gyroThreshold.toStringAsFixed(2)} rad/s"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Sensor Data Cards
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Accelerometer",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildSensorValue("X", _lastAccelerometer?.x),
                    _buildSensorValue("Y", _lastAccelerometer?.y),
                    _buildSensorValue("Z", _lastAccelerometer?.z),
                    SizedBox(height: 5),
                    _buildMagnitudeValue(
                        "Magnitude",
                        _lastAccMagnitudes.isNotEmpty ?
                        _lastAccMagnitudes.last : null
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Gyroscope",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildSensorValue("X", _lastGyroscope?.x),
                    _buildSensorValue("Y", _lastGyroscope?.y),
                    _buildSensorValue("Z", _lastGyroscope?.z),
                    SizedBox(height: 5),
                    _buildMagnitudeValue(
                        "Magnitude",
                        _lastGyroMagnitudes.isNotEmpty ?
                        _lastGyroMagnitudes.last : null
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleListening,
                  icon: Icon(_isListening ? Icons.pause : Icons.play_arrow),
                  label: Text(_isListening ? "Pause" : "Start"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _clearBuffer,
                  icon: Icon(Icons.clear),
                  label: Text("Clear All"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Information Text
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isSpikeDetected ? Colors.orange[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(
                    _isSpikeDetected ? Icons.warning : Icons.info,
                    color: _isSpikeDetected ? Colors.orange : Colors.blue,
                    size: 24,
                  ),
                  SizedBox(height: 8),
                  Text(
                    _isSpikeDetected ?
                    "Motion detected! Sending data to server..." :
                    "Monitoring sensor data...\nData will be sent only when spikes are detected",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isSpikeDetected ? Colors.orange[800] : Colors.blue[800],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorValue(String axis, double? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$axis:",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value != null ? value.toStringAsFixed(4) : "N/A",
            style: TextStyle(
              fontFamily: 'Monospace',
              fontSize: 14,
              color: value != null ? Colors.black : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagnitudeValue(String label, double? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value != null ? value.toStringAsFixed(4) : "N/A",
            style: TextStyle(
              fontFamily: 'Monospace',
              fontSize: 14,
              color: value != null ?
              (value > (label.contains("Acc") ? _accThreshold : _gyroThreshold) ?
              Colors.red : Colors.black) : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showThresholdSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Adjust Sensitivity"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Acceleration Threshold: ${_accThreshold.toStringAsFixed(1)} m/s²"),
            Slider(
              value: _accThreshold,
              min: 0.5,
              max: 5.0,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _accThreshold = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text("Gyroscope Threshold: ${_gyroThreshold.toStringAsFixed(2)} rad/s"),
            Slider(
              value: _gyroThreshold,
              min: 0.1,
              max: 2.0,
              divisions: 19,
              onChanged: (value) {
                setState(() {
                  _gyroThreshold = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}

// Add this import for sqrt function
