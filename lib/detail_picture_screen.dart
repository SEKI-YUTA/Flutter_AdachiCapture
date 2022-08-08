import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_screen.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  Map<String, String> tagNameDic = {
    "adati": "足立アナウンサー",
    "sat": "佐藤アナウンサー",
    "Iwahara": "岩原アナウンサー"
  };
  String _message = "処理中。。。";
  var imgByteData;
  var _content;
  String? personName;
  double maxProbability = 0.0;

  @override
  void initState() {
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

    print("azure response");
    print(resp.body);

    var jsonData = json.decode(resp.body);
    maxProbability = 0.0;
    int personCount = jsonData["predictions"].length;
    print("length");
    print(personCount);

    for (int i = 0; i < personCount; i++) {
      var probability = jsonData["predictions"][i]["probability"];
      var tagName = jsonData["predictions"][i]["tagName"];
      print(probability);
      if (probability > maxProbability) {
        setState(() {
          maxProbability = probability;
          personName = tagName;
        });
      }
    }
    if (maxProbability < 0.6) {
      setState(() {
        personName = null;
        _message = "検出出来ませんでした";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Stack(
        children: [
          Expanded(child: Image.file(File(widget.imagePath))),
          personName != null
              ? Positioned(
                  bottom: 50,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              toPersonDetail(personName);
                            },
                            child: Text("${tagNameDic[personName]}の詳細ページへ行く")),
                      ],
                    ),
                  ),
                )
              : Positioned(
                  bottom: 50,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _message,
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ],
                    ),
                  ),
                )
        ],
      ),
    );
  }

  void toPersonDetail(String? personName) {
    print(personName);
    if (personName == null) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            // （2） 実際に表示するページ(ウィジェット)を指定する
            builder: (context) => DetailScreen(
                  personName: personName,
                )));
  }
}
