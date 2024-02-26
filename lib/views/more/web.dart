import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Чат с техподдержкой"),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[Colors.red, Colors.purple],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
        ),
        body: ChatWidget(),
      ),
    );
  }
}

class ChatWidget extends StatefulWidget {
  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}
class _ChatWidgetState extends State<ChatWidget> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebView(
          initialUrl: 'https://skynet.bitrix24site.ru',
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (String url) {
            _hideFooterAndSimulateClick();
            setState(() {
              _isLoading = false;
            });
          },
          onWebViewCreated: (WebViewController controller) {
            _webViewController = controller;
          },
        ),
        if (_isLoading)
          Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  void _hideFooterAndSimulateClick() async {
    try {
      await _webViewController.evaluateJavascript('''
        var elements = document.getElementsByClassName('bitrix-footer');
        if (elements.length > 0) {
          elements[0].style.display = 'none';
          
          // Имитация клика на другом элементе
          var otherElement = document.querySelector('[data-b24-crm-button-icon="openline"]');
          if (otherElement) {
            otherElement.click();
          }
        }
      ''');
    } catch (e) {
      print("Error while simulating click: $e");
    }
  }
}
