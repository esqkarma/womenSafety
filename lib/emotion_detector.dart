import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class EmotionDetector {
  late Interpreter _interpreter;
  bool _isLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/emotion_model.tflite');
      _isLoaded = true;
      print("✅ TFLite model loaded successfully.");
    } catch (e) {
      print("❌ Error loading TFLite model: $e");
      rethrow;
    }
  }

  Future<String> predictEmotion(img.Image image) async {
    if (!_isLoaded) return "Model not loaded";

    try {
      final input = _prepareImage(image);
      final batchInput = input.reshape([1, 48, 48, 3]);
      final output = List.filled(7, 0.0).reshape([1, 7]);

      _interpreter.run(batchInput, output);

      final probs = output[0] as List<double>;
      final maxIndex = probs.indexOf(probs.reduce((a, b) => a > b ? a : b));

      return _getEmotionLabel(maxIndex);
    } catch (e) {
      print("Error predicting emotion: $e");
      return "Error";
    }
  }

  List<List<List<double>>> _prepareImage(img.Image image) {
    final resized = img.copyResize(image, width: 48, height: 48);
    return List.generate(48, (i) {
      return List.generate(48, (j) {
        final pixel = resized.getPixel(j, i);
        final r = img.getRed(pixel) / 255.0;
        final g = img.getGreen(pixel) / 255.0;
        final b = img.getBlue(pixel) / 255.0;
        return [r, g, b];
      });
    });
  }

  String _getEmotionLabel(int index) {
    const emotions = [
      "Anger",
      "Disgust",
      "Fear",
      "Happiness",
      "Sadness",
      "Surprise",
      "Neutral"
    ];
    return emotions[index];
  }

  void close() {
    if (_isLoaded) _interpreter.close();
  }
}
