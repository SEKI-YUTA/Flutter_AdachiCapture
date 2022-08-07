import 'package:flutter/material.dart';
import './capture_screen.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CaptureScreen(),
    );
  }
}
