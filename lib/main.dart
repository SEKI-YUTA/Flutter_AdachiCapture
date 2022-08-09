import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import './capture_screen2.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MaterialApp(
    // theme: ThemeData.light().copyWith(primaryColor: Colors.red),
    // darkTheme: ThemeData.dark(),
    themeMode: ThemeMode.light,
    debugShowCheckedModeBanner: false,
    home: CaptureScreen2(firstCamera: firstCamera),
  ));
}
