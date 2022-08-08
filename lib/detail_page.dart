import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'DataStore.dart';

class DetailPage extends StatefulWidget {
  DetailPage({Key? key, required this.personName}) : super(key: key);
  String personName;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, String> profileImages = {
    "足立夏保": "https://www.ytv.co.jp/announce/adachi_kaho/images/img_main.jpg",
    "岩原大起": "https://www.ytv.co.jp/announce/iwahara_daiki/images/img_main.jpg",
    "佐藤佳奈": "https://www.ytv.co.jp/announce/sato_kana/images/img_main.jpg",
  };
  String? name;
  int? age;
  String? comeFrom;
  List<String>? links;
  TextStyle prefixStyle = TextStyle(fontSize: 20);
  TextStyle itemStyle = TextStyle(fontSize: 26);
  TextStyle linkStyle = TextStyle(fontSize: 14, color: Colors.blue[800]);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // name = Dataset.name;
    // age = Dataset.age;
    // comeFrom = Dataset.comefrom;
    // links = Dataset.links;
    name = Dataset.personsData[widget.personName]["name"];
    age = Dataset.personsData[widget.personName]["age"];
    comeFrom = Dataset.personsData[widget.personName]["comefrom"];
    links = Dataset.personsData[widget.personName]["links"];
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
        padding: EdgeInsets.only(top: 60, left: 20, right: 20),
        child: Column(
          children: [
            Image.network(profileImages[name]!),
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
                Expanded(child: Text(age.toString(), style: itemStyle), flex: 1)
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
              children: links!
                  .map((e) => InkWell(
                        child: Text(
                          e,
                          style: linkStyle,
                        ),
                        onTap: () async => {launchUrl(Uri.parse(e))},
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () =>
                    {launchUrl(Uri.parse("https://lin.ee/NKKmZgz"))},
                child: Text("足立Botを使う"))
          ],
        ),
      ),
    );
  }

  // List<Widget> getLinksArea() {
  //   List<Widget> linkItems = [];
  //   for (int i = 0; i < links!.length; i++) {
  //     Widget item = Row(
  //       children: [Text(links![i], style: linkStyle)],
  //     );
  //     linkItems.add(item);
  //   }

  //   return linkItems;
  // }
}
