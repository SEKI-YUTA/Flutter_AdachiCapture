class Dataset {
  // static String name = "足立夏保";
  // static int age = 23;
  // static String comefrom = "シンガポール";
  // static List<String> links = [
  //   "https://ja.wikipedia.org/wiki/%E8%B6%B3%E7%AB%8B%E5%A4%8F%E4%BF%9D",
  //   "https://www.ytv.co.jp/announce/adachi_kaho/"
  // ];
  List<String> nameList = ["足立アナウンサー", "岩原アナウンサー", "佐藤アナウンサー"];
  static Map<String, dynamic> personsData = {
    "足立アナウンサー": {
      "name": "足立夏保",
      "age": 23,
      "comefrom": "シンガポール",
      "links": [
        "https://www.ytv.co.jp/announce/adachi_kaho/"
            "https://ja.wikipedia.org/wiki/%E8%B6%B3%E7%AB%8B%E5%A4%8F%E4%BF%9D",
      ]
    },
    "岩原アナウンサー": {
      "name": "岩原大起",
      "age": 27,
      "comefrom": "高知県",
      "links": [
        "https://www.ytv.co.jp/announce/iwahara_daiki/"
            "https://ja.wikipedia.org/wiki/%E5%B2%A9%E5%8E%9F%E5%A4%A7%E8%B5%B7",
      ]
    },
    "佐藤アナウンサー": {
      "name": "佐藤佳奈",
      "age": 25,
      "comefrom": "千葉県",
      "links": [
        "https://www.ytv.co.jp/announce/sato_kana/"
            "https://ja.wikipedia.org/wiki/%E4%BD%90%E8%97%A4%E4%BD%B3%E5%A5%88",
      ]
    }
  };
}
