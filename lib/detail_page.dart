import 'package:flutter/material.dart';
import 'DataStore.dart';

class DetailPage extends StatefulWidget {
  DetailPage({Key? key, required this.personName}) : super(key: key);
  String personName;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String? name;
  int? age;
  String? comeFrom;
  List<String>? links;

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
    return const Scaffold(
      body: Center(
        child: Text("Detil Page"),
      ),
    );
  }
}
