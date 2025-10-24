import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SOSVolumeService {
  static const platform = MethodChannel('volume.channel');
  static bool _active = false; // listener active only on user pages

  static void start(Function onSOS) {
    if (_active) return; // already active
    _active = true;

    platform.setMethodCallHandler((call) async {
      if (call.method == 'tripleVolumePressed' && _active) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool? userLogged = prefs.getBool('userLogged');

        if (userLogged == true) {
          Fluttertoast.showToast(msg: "🚨 SOS Triggered!");
          onSOS();
        } else {
          return;
        }
      }
      return;
    });
  }

  static void stop() {
    _active = false;
  }
}
