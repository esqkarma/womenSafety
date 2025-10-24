import 'package:flutter/material.dart';
import 'package:shecare/pinkhm/screens/cart_screen.dart';
import 'package:shecare/pinkhm/screens/home_screen.dart';
import 'package:shecare/pinkhm/screens/login_screen.dart';
import 'package:shecare/pinkhm/screens/main_screen.dart';
import 'package:shecare/pinkhm/screens/signup_screen.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
  //   SystemUiOverlay.bottom, //This line is used for showing the bottom bar
  // ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PinkMainScreen(),
      routes: {
        // LoginScreen.id: (context) => const LoginScreen(),
        // SignupScreen.id: (context) => const SignupScreen(),
        PinkMainScreen.id: (context) => const PinkMainScreen(),
        // HomeScreen.id: (context) => const HomeScreen(),
        // CartScreen.id: (context) => const CartScreen(),
      },
    );
  }
}
