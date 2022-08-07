import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './detail_page.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class CaptureScreen extends StatefulWidget {
  @override
  CaptureScreenState createState() => CaptureScreenState();
}

class CaptureScreenState extends State<CaptureScreen> {
  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image; //for captured image
  var binaryData;
  int? sWidth;
  int? sHeight;
  var _content;

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![0], ResolutionPreset.max);
      //cameras[0] = first camera, change to 1 to another camera

      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      print("NO any camera found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("足立キャプチャー"),
        backgroundColor: Colors.redAccent,
      ),
      body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Expanded(
            child: Stack(children: [
              Expanded(
                child: controller == null
                    ? const Center(child: Text("Loading Camera..."))
                    : !controller!.value.isInitialized
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : CameraPreview(controller!),
              ),
              Positioned(
                bottom: 50,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        //image capture button
                        onPressed: () async {
                          print("Captureing...");
                          try {
                            if (controller != null) {
                              //check if contrller is not null
                              if (controller!.value.isInitialized) {
                                //check if controller is initialized
                                image = await controller!.takePicture();
                                saveImage(File(image!.path)); //capture image
                                setState(() {
                                  //update UI
                                });
                              }
                            }
                          } catch (e) {
                            print(e); //show error
                          }
                        },
                        icon: const Icon(Icons.camera),
                        label: const Text("Capture"),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (image == null) {
                              return;
                            }
                            // print("Hello");
                            // Map<String, dynamic> fetchedData;
                            // Uri uri = Uri.parse(
                            //     "https://weather.tsukumijima.net/api/forecast/city/400040");
                            // http.get(uri).then((res) {
                            //   print("fetching");
                            //   String resBody = utf8.decode(res.bodyBytes);
                            //   fetchedData = jsonDecode(resBody);

                            //   print(fetchedData.toString());
                            // });
                            sendDataByByte();
                            print("imageFilePath" + image!.path);

                            // Uri uri = Uri.parse(
                            //     "https://weather.tsukumijima.net/api/forecast/city/400040");
                            // http.get(uri).then((res) {
                            //   print("fetched");
                            //   print(res.body);
                            // });
                          },
                          child: const Text("デバッグ用"))
                    ],
                  ),
                ),
              ),
            ]),
          )),
    );
  }

  void saveImage(File file) async {
    Uint8List data = file.readAsBytesSync();
    final result =
        await ImageGallerySaver.saveImage(data, quality: 100, name: "saved");
    print(result); // if (result) {
    //   print("画像が保存できました");
    // } else {
    //   print("保存に失敗しました");
    // }
  }

  void sendDataByByte() async {
    if (image == null) return;
    var file = File(image!.path);
    // var binary = file.readAsBytes();
    Uint8List data = await file.readAsBytes();
    ByteData bytes = ByteData.view(data.buffer);
    final byte1 = bytes.getUint64(0);
    print("byteData");
    print(byte1.toString());
    String url =
        "https://japaneast.api.cognitive.microsoft.com/customvision/v3.0/Prediction/df8b1072-cbf1-4b76-a03e-f810b9e75b2e/detect/iterations/Iteration3/image";
    Map<String, String> headers = {
      'Content-type': 'application/json',
      // 'Ocp-Apim-Subscription-Key': '{17812ecc9a5c4b249c42038bd5d58d30}'
      'Prediction-Key': '003dff7ccfda4c5aa9ba7d98f7f31098'
    };
    String body = json.encode({"data": byte1.toString()});

    http.Response resp =
        await http.post(Uri.parse(url), headers: headers, body: body);
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
    var probability = jsonData["predictions"][0]["probability"];
    print(probability);
    print(probability.runtimeType);
    if (probability > 0.9) {
      // toAdachiDetail();
    } else {
      print("else");
    }
  }

  void sendDataByUrl() async {
    String url =
        "https://japaneast.api.cognitive.microsoft.com/customvision/v3.0/Prediction/df8b1072-cbf1-4b76-a03e-f810b9e75b2e/detect/iterations/Iteration3/url";
    Map<String, String> headers = {
      'Content-type': 'application/json',
      // 'Ocp-Apim-Subscription-Key': '{17812ecc9a5c4b249c42038bd5d58d30}'
      'Prediction-Key': '003dff7ccfda4c5aa9ba7d98f7f31098'
    };
    String body = json.encode({
      "Url": "https://www.ytv.co.jp/announce/adachi_kaho/images/img_main.jpg"
    });

    http.Response resp =
        await http.post(Uri.parse(url), headers: headers, body: body);
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

    print("azure response");
    print(resp.body);

    var jsonData = json.decode(resp.body);
    var probability = jsonData["predictions"][0]["probability"];
    print(probability);
    print(probability.runtimeType);
    if (probability > 0.9) {
      // toAdachiDetail();
    } else {
      print("else");
    }
  }

  // void toAdachiDetail() {
  //   print("navigate");
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           // （2） 実際に表示するページ(ウィジェット)を指定する
  //           builder: (context) => const DetailPage()));
  // }
}
