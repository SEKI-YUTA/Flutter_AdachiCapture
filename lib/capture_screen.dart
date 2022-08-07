import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './detail_page.dart';

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
                child: SizedBox(
                    child: controller == null
                        ? const Center(child: Text("Loading Camera..."))
                        : !controller!.value.isInitialized
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : CameraPreview(controller!)),
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
                                image = await controller!
                                    .takePicture(); //capture image
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
                            sendData();
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

  void sendData() async {
    // File file = File(fileBits, fileName)

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
      toAdachiDetail();
    } else {
      print("else");
    }
  }

//   void _request() async {
//   String url = "https://httpbin.org/post";
//   Map<String, String> headers = {'content-type': 'application/json'};
//   String body = json.encode({'name': 'moke'});

//   http.Response resp = await http.post(url, headers: headers, body: body);
//   if (resp.statusCode != 200) {
//     setState(() {
//       int statusCode = resp.statusCode;
//       _content = "Failed to post $statusCode";
//     });
//     return;
//   }
//   setState(() {
//     _content = resp.body;
//   });
// }

  void toAdachiDetail() {
    print("navigate");
    Navigator.push(
        context,
        MaterialPageRoute(
            // （2） 実際に表示するページ(ウィジェット)を指定する
            builder: (context) => const DetailPage()));
  }
}
