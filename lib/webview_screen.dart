import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class WebViewScreen extends StatefulWidget {
  WebViewScreen({Key? key, required this.pageUrl}) : super(key: key);
  String pageUrl;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: () => {}, icon: Icon(Icons.more_vert))],
      ),
      body: WebView(
        initialUrl: widget.pageUrl,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
