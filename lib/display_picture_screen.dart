import 'dart:io';

import 'package:adachi_capture/DataStore.dart';
import 'package:adachi_capture/SecretInfo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_screen.dart';
import './DataStore.dart';

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
  String _message = "";
  // 画像のバイナリデータ
  var imgByteData;
  // Azureのレスポンス
  var _content;
  // アナウンサーの情報(json)
  var personsData;
  var detectedPersonData;
  String? personName;
  double maxProbability = 0.0;

  @override
  void initState() {
    super.initState();
    print("image path");
    print(widget.imagePath);
    // sendDataByByte(widget.imagePath);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startDialog(widget.imagePath);
    });
  }

  void startDialog(String imgPath) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
              child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(
                        width: 10,
                      ),
                      Text("処理中です。")
                    ],
                  )));
        });
    // コード改修の際に無駄にリクエストを送らないようにするためにコメントアウトする
    await Future.wait([sendDataByByte(imgPath), getPersonsData()]);

    // こっちは別にコメントアウトしなくてOK

    Navigator.of(context).pop();
  }

  Future<void> getPersonsData() async {
    // curl -H "X-Cybozu-API-Token: QH8RCWNDu0bjXh2P1yKwxGt5vUKyrYAay4oKO87w" "https://tvd42re6v9r9.cybozu.com/k/v1/records.json?app=7"
    var res = await http.get(
        Uri.parse("https://tvd42re6v9r9.cybozu.com/k/v1/records.json?app=7"),
        headers: {
          "X-Cybozu-API-Token": "QH8RCWNDu0bjXh2P1yKwxGt5vUKyrYAay4oKO87w"
        });
    var rawRes = utf8.decode(res.bodyBytes);
    personsData = json.decode(rawRes);

    print("personsData");
    print(personsData.toString());

    setState(() {
      personsData = personsData;
    });
  }

  Future<void> sendDataByByte(String imgPath) async {
    // XFile? file =  await ImagePicker().pickImage(source: ImageSource);
    File file = File(imgPath);
    imgByteData = file.readAsBytesSync();

    String url = SecretInfo.azureEndpoint;
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Prediction-Key': SecretInfo.predictionKey
    };
    var body = imgByteData;

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

    var jsonData = json.decode(resp.body);
    maxProbability = 0.0;
    int personCount = jsonData["predictions"].length;

    for (int i = 0; i < personCount; i++) {
      var probability = jsonData["predictions"][i]["probability"];
      var tagName = jsonData["predictions"][i]["tagName"];
      print("tagName");
      print(jsonData["predictions"][i]["tagName"]);
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
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.yellow,
      ),
      body: Stack(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Expanded(
                child: Image.file(File(widget.imagePath)),
              )),
          personName != null && personsData != null
              ? SimpleProfile(context)
              : UserMessage(context)
        ],
      ),
    );
  }

  Widget SimpleProfile(BuildContext context) {
    print("simpleProfile");
    var detectPersonData;
    for (int i = 0; i < personsData["records"].length; i++) {
      print(personsData["records"][i]["name"]["value"].toString());
      print(personsData["records"][i]["_name"]["value"].toString());
      if (personName ==
          personsData["records"][i]["_name"]["value"].toString()) {
        detectPersonData = personsData["records"][i];
        print("matched");
      }
    }
    setState(() {
      detectedPersonData = detectPersonData;
    });
    Dataset.personsData["detectedPerson"] = detectedPersonData;
    return Positioned(
      bottom: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(0, 0, 0, 0),
          Color.fromARGB(0, 0, 0, 0),
          Color.fromARGB(0, 0, 0, 0),
          Color.fromARGB(0, 0, 0, 0),
          Color.fromARGB(50, 0, 0, 0),
          Color.fromARGB(200, 0, 0, 0)
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              height: 140,
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      "${detectPersonData["name"]["value"]} ${detectPersonData["age"]["value"]}歳",
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () async {
                            toPersonDetail(personName);
                          },
                          child: Text(
                            "${detectPersonData["name"]["value"]}の詳細ページへ行く",
                            style: const TextStyle(color: Colors.white60),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget UserMessage(BuildContext context) {
    print("UserMessage");
    return Positioned(
      bottom: 50,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _message,
              style: const TextStyle(color: Colors.red, fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }

  void toPersonDetail(String? personName) {
    print(personName);
    print(Dataset.personsData["detectedPerson"]);
    if (personName == null) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailScreen(
                  detectPersonData: Dataset.personsData["detectedPerson"],
                )));
  }
}
