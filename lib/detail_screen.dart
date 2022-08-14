// import 'package:adachi_capture/webview_screen.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key, required this.detectPersonData})
      : super(key: key);
  final Map<String, dynamic> detectPersonData;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // DataStoreに移行
  // Map<String, String> profileImages = {
  //   "足立夏保": "https://www.ytv.co.jp/announce/adachi_kaho/images/img_main.jpg",
  //   "岩原大起": "https://www.ytv.co.jp/announce/iwahara_daiki/images/img_main.jpg",
  //   "佐藤佳奈": "https://www.ytv.co.jp/announce/sato_kana/images/img_main.jpg",
  // };
  static const platform = MethodChannel("adachi.capture.line/intent");
  String specialPerson = "足立夏保";
  String? name;
  int? age;
  String? comeFrom;
  String? profileImgLink;
  List<String>? links;
  TextStyle prefixStyle = const TextStyle(fontSize: 16);
  TextStyle itemStyle = const TextStyle(fontSize: 20);
  TextStyle linkStyle = TextStyle(fontSize: 14, color: Colors.blue[800]);

  Future<void> _lineIntent() async {
    await platform.invokeListMethod("sendLineIntent");
  }

  @override
  void initState() {
    super.initState();
    // name = Dataset.name;
    // age = Dataset.age;
    // comeFrom = Dataset.comefrom;
    // links = Dataset.links;
    name = widget.detectPersonData["name"]["value"];
    age = int.parse(widget.detectPersonData["age"]["value"]);
    comeFrom = widget.detectPersonData["comefrom"]["value"];
    links = widget.detectPersonData["links"]["value"].toString().split("|");
    profileImgLink = widget.detectPersonData["profileImg"]["value"];
    print(name);
    print(age);
    print(comeFrom);
    for (int i = 0; i < links!.length; i++) {
      print(links![i]);
      print("\n");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(profileImgLink!),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text("名前:", style: prefixStyle),
                  Expanded(child: Text(name!, style: itemStyle), flex: 1)
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text("年齢:", style: prefixStyle),
                  Expanded(
                      child: Text("${age.toString()}歳", style: itemStyle),
                      flex: 1)
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text("出身地:", style: prefixStyle),
                  Expanded(child: Text(comeFrom!, style: itemStyle), flex: 1)
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("リンク集"),
                  ...links!
                      .map((e) => InkWell(
                            child: Text(
                              e,
                              style: linkStyle,
                            ),
                            onTap: () async => {launchUrl(Uri.parse(e))},
                          ))
                      .toList()
                ],
              ),
              const SizedBox(height: 10),
              name == specialPerson
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.yellow),
                      onPressed: () {
                        // 方法1 url_launcherで起動しようとしてもエラー
                        // launchUrl(Uri.parse("https://lin.ee/NKKmZgz"));
                        // 方法2 web_viewをアプリに組み込んでも同じくエラー
                        // Navigator.of(context).push(new MaterialPageRoute(
                        //     builder: (context) => WebViewScreen(
                        //         pageUrl: "https://lin.ee/NKKmZgz")));
                        // 方法3 ネイティブコードからインテントを飛ばすとうまくラインが立ち上がる
                        _lineIntent();
                      },
                      child: const Text(
                        "足立Botを使ってみる",
                        style: TextStyle(color: Colors.black54),
                      ))
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
