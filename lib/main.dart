import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import './capture_screen2.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CaptureScreen2(firstCamera: firstCamera),
  ));
}
