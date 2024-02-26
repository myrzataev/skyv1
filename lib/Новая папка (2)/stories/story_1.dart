import 'package:flutter/material.dart';

class MyStory1 extends StatelessWidget {
  final String imageUrl;
  final String text;

  const MyStory1({Key? key, required this.imageUrl, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(imageUrl), // Отобразить изображение из URL
            SizedBox(height: 20),
            Text(text), // Отобразить текст
          ],
        ),
      ),
    );
  }
}
