import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import './detail_page.dart';

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
    // TODO: implement initState
    super.initState();
    _controller = CameraController(widget.firstCamera, ResolutionPreset.high);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("足立キャプチャー"),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List<String> nameList = ["足立アナウンサー", "岩原アナウンサー", "佐藤アナウンサー"];
  var imgByteData;
  var _content;
  String? personName;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("image path");
    print(widget.imagePath);
    sendDataByByte(widget.imagePath);
  }

  void sendDataByByte(String imgPath) async {
    // XFile? file =  await ImagePicker().pickImage(source: ImageSource);
    File file = File(imgPath);
    imgByteData = file.readAsBytesSync();

    String url =
        "https://japaneast.api.cognitive.microsoft.com/customvision/v3.0/Prediction/df8b1072-cbf1-4b76-a03e-f810b9e75b2e/detect/iterations/Iteration3/image";
    Map<String, String> headers = {
      'Content-type': 'application/json',
      // 'Ocp-Apim-Subscription-Key': '{17812ecc9a5c4b249c42038bd5d58d30}'
      'Prediction-Key': '003dff7ccfda4c5aa9ba7d98f7f31098'
    };
    // String body = json.encode({"data": byte1.toString()});
    var body = imgByteData;
    ;

    http.Response resp =
        await http.post(Uri.parse(url), headers: headers, body: body);
    print("statuc code");
    print(resp.statusCode);
    if (resp.statusCode != 200) {
      setState(() {
        int statusCode = resp.statusCode;
        _content = "Failed to post $statusCode";
      });
      return;
    }
    setState(() {
      _content = resp.body;
    });

    // print("azure response");
    // print(resp.body);

    var jsonData = json.decode(resp.body);
    double maxProbability = 0.0;
    int personCount = jsonData["predictions"].length;
    print("length");
    print(personCount);

    for (int i = 0; i < personCount; i++) {
      var probability = jsonData["predictions"][0]["probability"];
      print(probability);
      if (probability > maxProbability) {
        setState(() {
          maxProbability = probability;
          personName = nameList[i];
        });
      }
      ;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Stack(
        children: [
          Expanded(child: Image.file(File(widget.imagePath))),
          personName != null
              ? ElevatedButton(
                  onPressed: () {
                    toAdachiDetail(personName);
                  },
                  child: Text("$personNameの詳細ページへ行く"))
              : Text("")
        ],
      ),
    );
  }

  void toAdachiDetail(String? personName) {
    print("navigate");
    print(personName);
    if (personName == null) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            // （2） 実際に表示するページ(ウィジェット)を指定する
            builder: (context) => DetailPage(
                  personName: personName,
                )));
  }
}
