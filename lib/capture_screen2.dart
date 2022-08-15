import 'display_picture_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CaptureScreen2 extends StatefulWidget {
  List<CameraDescription>? cameras;
  CameraDescription firstCamera;
  CaptureScreen2({Key? key, required this.firstCamera}) : super(key: key);

  @override
  State<CaptureScreen2> createState() => _CaptureScreen2State();
}

class _CaptureScreen2State extends State<CaptureScreen2> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    checkNetwork();
    _controller = CameraController(widget.firstCamera, ResolutionPreset.high);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void checkNetwork() async {
    var connectivity_status = await (Connectivity().checkConnectivity());
    if (!(connectivity_status == ConnectivityResult.wifi) &&
        !(connectivity_status == ConnectivityResult.mobile)) {
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return WillPopScope(
                child: Scaffold(
                    backgroundColor: Color.fromARGB(100, 0, 0, 0),
                    body: Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "ネットワークに接続してください",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                        ],
                      ),
                    )),
                onWillPop: () async => false);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.black87),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 100,
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      iconSize: 60,
                      onPressed: takePicAndDisplay,
                      icon: const Icon(
                        Icons.camera,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 30,
            child: IconButton(
                iconSize: 50,
                onPressed: () async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null && image.path != null) {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisplayPictureScreen(
                          imagePath: image.path,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.image,
                  color: Colors.white,
                )),
          )
        ],
      ),
    );
  }

  void takePicAndDisplay() async {
    try {
      await _initializeControllerFuture;

      final image = await _controller.takePicture();

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            imagePath: image.path,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
