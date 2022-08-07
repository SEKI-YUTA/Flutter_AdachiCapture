import 'package:flutter/material.dart';
import 'Adachi.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

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
    name = Dataset.name;
    age = Dataset.age;
    comeFrom = Dataset.comefrom;
    links = Dataset.links;
    print(name);
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
