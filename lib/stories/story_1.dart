import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyStory1 extends StatelessWidget {
  final String icon;
  final String imageUrl;

  const MyStory1({Key? key, required this.icon, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],

      body: Center(
        child: Expanded(
          child: Image.network(imageUrl, fit: BoxFit.cover), // Изображение на полный экран
        ),
      ),
    );
  }
}
